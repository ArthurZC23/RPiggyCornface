local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local StateTypesServer = require(ComposedKey.getAsync(ReplicatedStorage, {
    "StateManager", "Shared", "GameState", "StateTypesServer"}
))

local RootFolder = script.Parent
local StateTypes = {
    Session = require(RootFolder.GameSession.GameSession),
}

local GameState = {}
GameState.__index = GameState
GameState.className = "GameState"
GameState.TAG_NAME = GameState.className

-- Should game state have persistant state? Yes, this could be state that is synced from
-- a datastore from time to time. For instance, an announcement.

function GameState.new()
    local self = {}
    setmetatable(self, GameState)
    self._maid = Maid.new()

    self.stateReplicationConditions = {
        Session = false,
    }

    self._stateTypes = {}
    for _, stateType in ipairs(StateTypesServer.array) do
        self._stateTypes[stateType] = self._maid:Add(StateTypes[stateType].new(self))
    end

    return self
end

function GameState:updateReplicationConditions(condition)
    self.stateReplicationConditions[condition] = true
    --print("------------------- PlayerState")
    --TableUtils.print(self.stateReplicationConditions)
    local canReplicate = true
    for _, boolVal in pairs(self.stateReplicationConditions) do
        canReplicate = canReplicate and boolVal
    end
    --print("canReplicate: ", canReplicate)
    --print("---------------")
    self.canReplicateState = canReplicate
end

function GameState:get(stateType, scope)
    return self._stateTypes[stateType]:get(scope)
end

function GameState:set(stateType, scope, action)
    local kwargs = self._stateTypes[stateType]:set(scope, action)
    return kwargs
end

function GameState:getEvent(stateType, scope, eventName)
    return self._stateTypes[stateType]:getEvent(scope, eventName)
end

function GameState:getAllEvents(stateType)
    return self._stateTypes[stateType].allSignal
end

function GameState:Destroy()
    self._maid:Destroy()
end

return GameState