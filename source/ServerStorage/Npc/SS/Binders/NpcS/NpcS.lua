local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local NpcsData = Data.Npcs.Npcs
local NpcsTags = Data.Npcs.Tags
local HumanoidStates = Data.Npcs.HumanoidStates
local Collisions = Mod:find({"Collisions"})
local CollisionsGroups = Data.Collisions.CollisionGroupsData
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local TableUtils = Mod:find({"Table", "Utils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local EzRefUtils = Mod:find({"EzRef", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local NpcS = {}
NpcS.__index = NpcS
NpcS.className = "Npc"
NpcS.TAG_NAME = NpcS.className

-- Similar to PlayerCharacterS
function NpcS.new(char)
    if not char:IsDescendantOf(workspace) then return end
    local npcId = char:GetAttribute("NpcId") -- id is not unique
    local npcData = NpcsData.npcs[npcId]
    assert(npcId, ("Npc %s doesn't have id."):format(char:GetFullName()))
    assert(npcData, ("Npc %s doesn't have data."):format(char:GetFullName()))

    local self = {
        _maid = Maid.new(),
        char = char,
        npcId = npcId,
        npcData = npcData,
    }
    setmetatable(self, NpcS)

    self:addUidToChar(char)
    if not self:getFields() then return end
    self:setCollisionGroup(char)
    self:createAnimator(char)
    self:setNetworkOwner()
    self:setAllowedHumanoidStates()
    self:loadTags()

    self.char:SetAttribute("IsAppearanceLoaded", true)

    return self
end

function NpcS:addUidToChar(char)
    local uid = (("npc%s_%s"):format(self.npcId, tostring(os.clock())))
    self.char:SetAttribute("uid", uid)
    self._maid:Add(EzRefUtils.addEzRef(char, ("Char_%s"):format(uid)))
end

function NpcS:createAnimator()
    local animator = self.humanoid:FindFirstChild("Animator")
    if not animator then
        animator = GaiaShared.create("Animator", {Parent = self.humanoid})
    end
end

function NpcS:loadTags()
    -- load npcType and npc tags
    for _, tag in ipairs(NpcsTags.tags[self.npcData.npcType]) do
        CollectionService:AddTag(self.char, tag)
    end
    if self.npcData.tags then
        for _, tag in ipairs(self.npcData.tags) do
            CollectionService:AddTag(self.char, tag)
        end
    end
end

function NpcS:setCollisionGroup(char)
    local collisionGroup = CollisionsGroups.names[char:GetAttribute("CollisionGroup") or "Npc"]
    for _, child in ipairs(char:GetChildren()) do
        if not child:IsA("BasePart") then continue end
        Collisions.setCollisionGroup(child, collisionGroup)
    end
end

function NpcS:setNetworkOwner()
    local networkOwner = self.char:FindFirstChild("NetworkOwner")
    if networkOwner then networkOwner = networkOwner.Value end

    if not self.hrp.Anchored then
        for _, desc in ipairs(self.char:GetDescendants()) do
            if not desc:IsA("BasePart") then continue end
            desc:SetNetworkOwner(networkOwner)
        end
    end
end

function NpcS:setAllowedHumanoidStates()
    local humanoidStates = HumanoidStates[self.npcData.npcType]
    for humState, val in pairs(humanoidStates) do
        self.humanoid:SetStateEnabled(humState, val)
    end
end

function NpcS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.humanoid = self.char:FindFirstChild("Humanoid")
            if not self.humanoid then return end

            self.hrp = self.char:FindFirstChild("HumanoidRootPart")
            if not self.hrp then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function NpcS:Destroy()
    self._maid:Destroy()
end

return NpcS