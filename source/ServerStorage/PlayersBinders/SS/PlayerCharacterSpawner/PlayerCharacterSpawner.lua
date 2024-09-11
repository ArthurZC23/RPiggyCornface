local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})

local PlayerCharacterSpawner = {}
PlayerCharacterSpawner.__index = PlayerCharacterSpawner
PlayerCharacterSpawner.className = "PlayerCharacterSpawner"
PlayerCharacterSpawner.TAG_NAME = PlayerCharacterSpawner.className

PlayerCharacterSpawner.spawnAreaId = 1

local Sampler = Mod:find({"Math", "Sampler"})
PlayerCharacterSpawner.spawnSampler = Sampler.new()

function PlayerCharacterSpawner.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
        firstSpawn = true,
    }
    setmetatable(self, PlayerCharacterSpawner)

    if not self:getFields(player) then return end

    self:createRemotes()
    self:createSignals()
    -- self:handleSpawnUpdate() -- Need to be local, but spawns doesn't follow local configs
    self:handleCharSpawn(player)

    return self
end

-- function PlayerCharacterSpawner:handleSpawnUpdate()
--     for i, Spawn in ipairs(CollectionService:GetTagged("SpawnLocation")) do
--         Spawn.Enabled = false
--     end

--     local function update(state, action)
--         do
--             local worldId = state.current
--             local World = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace, refName=("World%s"):format(worldId)})
--             local Spawns = SharedSherlock:find({"EzRef", "Get"}, {inst=World, refName=("Spawns"):format(worldId)})
--             for _, Spawn in ipairs(Spawns.Model:GetChildren()) do
--                 Spawn.Enabled = true
--             end
--         end
--         if action.previous then
--             local worldId = action.previous
--             local World = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace, refName=("World%s"):format(worldId)})
--             local Spawns = SharedSherlock:find({"EzRef", "Get"}, {inst=World, refName=("Spawns"):format(worldId)})
--             for _, Spawn in ipairs(Spawns.Model:GetChildren()) do
--                 Spawn.Enabled = false
--             end
--         end
--     end
--     self._maid:Add(self.playerState:getEvent(S.Session, "Worlds", "setCurrentWorld"):Connect(update))
--     local state = self.playerState:get(S.Session, "Worlds")
--     update(state, {})

-- end

function PlayerCharacterSpawner:spawn(playerState)
    local player = playerState.player
    print("Team: ", player:GetAttribute("team"))

    if Data.Studio.Studio.spawnAsMonster then
        local monsterSkinState = playerState:get(S.Stores, "MonsterSkins")
        local Monster = Data.MonsterSkins.MonsterSkins.idData[monsterSkinState.eq].monsterModel:Clone()
        Monster:SetAttribute("rigType", "R15")
        Monster:SetAttribute("CoreAnimations", "Monster")
        Monster.Name = player.Name
        player.Character = Monster
        Monster.Parent = workspace.PlayersCharacters

        return Monster
    elseif player:GetAttribute("team") == "monster" then
        -- local monsterSkinState = playerState:get(S.Stores, "MonsterSkins")
        -- local Monster = Data.MonsterSkins.MonsterSkins.idData[monsterSkinState.eq].monsterModel:Clone()
        -- -- Monster:SetAttribute("charRunAnimationFactor", 1.5)
        -- Monster:SetAttribute("monsterId", "1")
        -- Monster:SetAttribute("NpcId", nil)
        -- Monster:SetAttribute("rigType", "R15")
        -- Monster:SetAttribute("CoreAnimations", "Monster")
        -- Monster.Humanoid.WalkSpeed = 0
        -- Monster:AddTag("PlayerMonster")
        -- -- Monster:AddTag("CharCoreAnimationsMonster")
        -- Monster:AddTag("Monster")
        -- Monster:SetAttribute("canKill", false)
        -- Monster:PivotTo(self.MonsterSpawn:GetPivot())
        -- local Humanoid = Monster.Humanoid

        -- Monster.Name = player.Name
        -- player.Character = Monster
        -- Monster.Parent = workspace.PlayersCharacters

        -- Promise.delay(3)
        -- :andThen(function()
        --     Humanoid.WalkSpeed = 16 - 0.5
        --     Monster:SetAttribute("canKill", true)
        -- end)
        -- return Monster
    elseif player:GetAttribute("team") == "Lobby" then
        player:LoadCharacter()
        local char = player.Character
        char:SetAttribute("rigType", "R15")
        return player.Character
    end
end

function PlayerCharacterSpawner:handleCharSpawn(player)
    local function spawnChar()
        if not player.Parent then return end
        if self.playerState.isDestroyed then return end

        local ok, char = pcall(function()
            return self:spawn(self.playerState)
        end)
        if ok then
            self.firstSpawn = false
            self:setPivot(char)
            self.CharSpawnedSE:Fire(char)
            self.CharSpawnedRE:FireClient(player)
        else
            local err = char
            warn(tostring(err))
        end
    end
    self.playerHades.CharRespawnSE:Connect(spawnChar)
    spawnChar()
end

function PlayerCharacterSpawner:createRemotes()
    local eventsNames = {"CharSpawned"}
    GaiaServer.createRemotes(self.player, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        self[("%sRE"):format(eventName)] = self.player.Remotes.Events[eventName]
    end
end

function PlayerCharacterSpawner:setPivot(char)
    if Data.Studio.Studio.testSpawnAllTime and RunService:IsStudio() and (not char:HasTag("Monster")) then
        local firstSpawnCf = workspace:GetAttribute("firstSpawnCf")
        char:PivotTo(CFrame.new(firstSpawnCf.Position))
        return
    end
    if Data.Studio.Studio.testSpawnOneTime and RunService:IsStudio() then
        local firstSpawnCf = workspace:GetAttribute("firstSpawnCf")
        if firstSpawnCf then
            workspace:SetAttribute("firstSpawnCf", nil)
            char:PivotTo(CFrame.new(firstSpawnCf.Position))
            return
        end
    end
end

function PlayerCharacterSpawner:createSignals()
    local eventsNames = {"CharSpawned"}
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.player, {
        events = eventsNames,
    }))
end

function PlayerCharacterSpawner:getFields(player)
    local ok = WaitFor.GetAsync({
        getter=function()

            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", player},
                {"PlayerHades", player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return player
        end,
        cooldown=1
    })
    return ok
end

function PlayerCharacterSpawner:Destroy()
    self._maid:Destroy()
end

return PlayerCharacterSpawner