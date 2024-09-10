local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local StateTypesServer = require(ComposedKey.getAsync(ReplicatedStorage, {
    "StateManager", "Shared", "GameState", "StateTypesServer"}
))

local RootFolder = script.Parent
local StateTypesInterfaces = {
    Session = require(RootFolder.PlayerGameSession.PlayerGameSession),
}

-- Responsible to interface and replicate game state not linked to the player.
local PlayerGameState = {}
PlayerGameState.__index = PlayerGameState
PlayerGameState.className = "PlayerGameState"
PlayerGameState.TAG_NAME = PlayerGameState.className

-- Player interface and replication to game state.
function PlayerGameState.new(player)
    local self = {}
    setmetatable(self, PlayerGameState)
    self.player = player
    self._maid = Maid.new()

    self.stateReplicationConditions = {
        ["Session"] = false,
    }

    self._stateTypes = {}
    for _, stateType in ipairs(StateTypesServer.array) do
        self._stateTypes[stateType] = self._maid:Add(StateTypesInterfaces[stateType].new(self))
    end

    local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerStateManagers"})
    self.stateManagers = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})

    return self
end

function PlayerGameState:updateReplicationConditions(condition)
    self.stateReplicationConditions[condition] = true
    -- print("------------------- PlayerGameState")
    -- TableUtils.print(self.stateReplicationConditions)
    local canReplicate = true
    for _, boolVal in pairs(self.stateReplicationConditions) do canReplicate = canReplicate and boolVal end
    -- print("canReplicate: ", canReplicate)
    -- print("---------------")
    if canReplicate then self.stateManagers:updateReplicationConditions("PlayerGameState") end
end

function PlayerGameState:Destroy()
    self._maid:Destroy()
end

return PlayerGameState