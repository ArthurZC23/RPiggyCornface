local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local CharTags = Data.Players.CharTags
local Collisions = Mod:find({"Collisions"})
local CollisionsGroups = Data.Collisions.CollisionGroupsData
local SignalUtils = Mod:find({"Signal", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local IdUtils = Mod:find({"Id", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local BigTable = Mod:find({"BigTable", "BigTable"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local EzRefUtils = Mod:find({"EzRef", "Utils"})

local charFolder = workspace:FindFirstChild("PlayersCharacters") or GaiaShared.create("Folder", {
    Name = "PlayersCharacters",
    Parent = workspace,
})

local charsEventsFolder = ReplicatedStorage:FindFirstChild("CharsEvents") or GaiaShared.create("Folder", {
    Name = "CharsEvents",
    Parent = ReplicatedStorage,
})
do
    local references = ReplicatedStorage:FindFirstChild("CharsEvents") or GaiaShared.create("Folder", {
        Name = "References",
        Parent = charsEventsFolder,
    })
end

local charIdGen = IdUtils.createNumIdGenerator()

local PlayerCharacterS = {}
PlayerCharacterS.__index = PlayerCharacterS
PlayerCharacterS.className = "PlayerCharacter"
PlayerCharacterS.TAG_NAME = PlayerCharacterS.className

function PlayerCharacterS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerCharacterS)

    if not self:getFields(char) then return end
    local ok = self:waitCharacterToBeReady(self.player, char)
    if not ok then return end
    self:reparentCharToFolder(char)
    self:setCollisionGroup(char)
    self:createAnimator(char)
    self:addUidToChar(char)
    self:setHumanoid()
    self:addCharEventsFolder(char)
    self:loadCharBinders(self.player, char)
    return self
end

function PlayerCharacterS:setHumanoid()
    self.humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

function PlayerCharacterS:addUidToChar(char)
    local id = charIdGen()
    do
        local debugUid = (("%s_%s_%s"):format(self.player.Name, tostring(self.player.UserId), id))
        char:SetAttribute("debugUid", debugUid)
    end
    do
        char:SetAttribute("uid", id)
        self._maid:Add(BigTable.set("uid", id, char))
    end
    self._maid:Add(EzRefUtils.addEzRef(char, ("Char_%s"):format(id)))
end

function PlayerCharacterS:addCharEventsFolder(char)
    local id = char:GetAttribute("uid")
    local charEvents = self._maid:Add(GaiaShared.create("Folder", {
        Name = id,
        Parent = charsEventsFolder,
    }))
end

function PlayerCharacterS:createAnimator(char)
    self.humanoid = char:FindFirstChild("Humanoid")
    if not self.humanoid then return end
    local animator = self.humanoid:FindFirstChild("Animator")
    if not animator then
        animator = GaiaShared.create("Animator", {Parent = self.humanoid})
    end
end

function PlayerCharacterS:setCollisionGroup(char)
    local collisionGroup = CollisionsGroups.names.Player

    local function update(child)
        if not child:IsA("BasePart") then return end
        Collisions.setCollisionGroupRecursive(child, collisionGroup)
    end

    char.ChildAdded:Connect(update)

    for _, child in ipairs(char:GetChildren()) do
       update(child)
    end
end

function PlayerCharacterS:loadCharBinders(player, char)
    for _, tagData in ipairs(CharTags.tags) do
        if typeof(tagData) == "table" then
            if not tagData.teams[self.player:GetAttribute("team")] then continue end
            CollectionService:AddTag(char, tagData.tag)
        else
            CollectionService:AddTag(char, tagData)
        end

        -- This is not necessary as other binders use getFields. This also halts if the binder is only on client.
        -- if CharTags.asyncTags[tag] then
        --     local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag=tag, cooldown = 0.15})
        --     local obj = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=char, cooldown = 0.15})
        --     if not obj then return end
        -- end
    end

    self._maid:Add2(WaitFor.BObj(player, "PlayerState"):andThen(function(playerState)
        -- E.g. Gps that alter something in the character
        self._maid:Add2(playerState:getEvent("Session", "CharTags", "removeTag"):Connect(function(_, action)
            char:RemoveTag(action.tag)
        end))

        self._maid:Add2(playerState:getEvent("Session", "CharTags", "addTag"):Connect(function(_, action)
            char:AddTag(action.tag)
        end))

        for tag, _ in pairs(playerState:get("Session", "CharTags")) do
            char:AddTag(tag)
        end
    end))
end

function PlayerCharacterS:waitCharacterToBeReady(player, char)
    if not char.Parent then
        SignalUtils.waitForFirst(char.AncestryChanged, player.CharacterAdded)
    end

    if player.Character ~= char or not char.Parent then
        return
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")

    while char:IsDescendantOf(game) and not humanoid do
        SignalUtils.waitForFirst(char.ChildAdded, char.AncestryChanged, player.CharacterAdded)
        humanoid = char:FindFirstChildOfClass("Humanoid")
    end

    if player.Character ~= char or not char:IsDescendantOf(game) then
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    while char:IsDescendantOf(game) and not hrp do
        SignalUtils.waitForFirst(char.ChildAdded, char.AncestryChanged, humanoid.AncestryChanged, player.CharacterAdded)
        hrp = char:FindFirstChild("HumanoidRootPart")
    end

    if
        hrp
        and humanoid:IsDescendantOf(game)
        and char:IsDescendantOf(game)
        and player.Character == char
    then
        return true
    end

    -- local t = 0
    -- local resetTimer = function ()
    --     t = 0
    -- end
    -- local conn = char.DescendantAdded:Connect(resetTimer)
    -- while t < 2 do
    --     local step = RunService.Heartbeat:Wait()
    --     t = t + step
    -- end
    -- conn:Disconnect()
    -- conn = nil
end

function PlayerCharacterS:reparentCharToFolder()
    if self.char.Parent == workspace then -- At this point is guaranteed that char.Parent is not nil anymore for a non destroyed char.
        task.wait() -- Avoid https://devforum.roblox.com/t/remove-the-something-unexpectedly-tried-to-set-the-parent-of-x-to-null-while-trying-to-set-the-parent-of-x/27414
        self.char.Parent = charFolder
    end
    -- task.wait() -- In case of the :GetCharacterFromPlayer problem
end

function PlayerCharacterS:getFields(char)
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(char)
            if not self.player then return end

            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function PlayerCharacterS:Destroy()
    self._maid:Destroy()
end

return PlayerCharacterS