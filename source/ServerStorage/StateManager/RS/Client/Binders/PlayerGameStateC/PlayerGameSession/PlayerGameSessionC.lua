local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
--local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Game.Session.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Game.Session.Signals

local localPlayer = Players.LocalPlayer

local GameSession = {}
GameSession.__index = GameSession

GameSession.stateType = "Session"

function GameSession.new()
    local self = {}
    setmetatable(self, GameSession)
    self.player = localPlayer

    self._maid = Maid.new()

    --self.scheduler = JobScheduler.new(function(job) self:_sync(unpack(job)) end)
    self.actionsQueue = {}

    local RFs = localPlayer
        :WaitForChild("Remotes")
        :WaitForChild("Functions")

    self.SetRequestGameSessionRF = RFs:WaitForChild("SetRequestGameSession")
    self.RequestGameSessionReplicaRF = RFs:WaitForChild("RequestGameSessionReplica")

    self.replica = self:getReplica()
    self.signals = self._maid:Add(ActionSignals.new(Signals))

    if not self.player.Parent then return end

    return self
end

function GameSession:getReplica()
    local replica = self.RequestGameSessionReplicaRF:InvokeServer()
    self._isStateLoaded = true
    for _, data in ipairs(self.actionsQueue) do
        self:_sync(unpack(data))
    end
    self.actionsQueue = nil
    return replica
end

function GameSession:get(scope)
    assert(self.replica[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.replica[scope]
end

-- used for replication
function GameSession:sync(scope, action)
    if self._isStateLoaded then
        self:_sync(scope, action)
    else
        self.actionsQueue = {}
    end
end

function GameSession:_sync(scope, action)
    local oldState = self:get(scope)
    local state = Actions.apply(scope, oldState, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function GameSession:requestToSet(scope, action)
    return self.SetRequestGameSessionRF:InvokeServer(scope, action)
end

function GameSession:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function GameSession:Destroy()
    self._maid:Destroy()
end


return GameSession