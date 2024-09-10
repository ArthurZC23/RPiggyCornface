local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
--local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Player.Session.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Player.Session.Signals

local PlayerSession = {}
PlayerSession.__index = PlayerSession

PlayerSession.stateType = "Session"

function PlayerSession.new(player)
    local self = {}
    setmetatable(self, PlayerSession)
    self.player = player

    self._maid = Maid.new()

    --self.scheduler = JobScheduler.new(function(job) self:_sync(unpack(job)) end)
    self.actionsQueue = {}

    local RFs = self.player
        :WaitForChild("Remotes")
        :WaitForChild("Functions")

    self.SetRequestPlayerSessionRF = RFs:WaitForChild("SetRequestPlayerSession")
    self.RequestPlayerSessionReplicaRF = RFs:WaitForChild("RequestPlayerSessionReplica")

    self.replica = self:getReplica()
    self.signals = self._maid:Add(ActionSignals.new(Signals))

    -- In case player left during yield.
    if not self.player.Parent then
        return
    end

    return self
end

function PlayerSession:getReplica()
    local replica = self.RequestPlayerSessionReplicaRF:InvokeServer()
    self._isStateLoaded = true
    for _, data in ipairs(self.actionsQueue) do
        self:_sync(unpack(data))
    end
    self.actionsQueue = nil
    return replica
end

function PlayerSession:get(scope)
    assert(self.replica[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.replica[scope]
end

-- used for replication
function PlayerSession:sync(scope, action)
    if self._isStateLoaded then
        self:_sync(scope, action)
    else
        table.insert(self.actionsQueue, {scope, action})
        --self.scheduler:pushJob({scope, action})
    end
end

function PlayerSession:_sync(scope, action)
    local oldState = self:get(scope)
    local state = Actions.apply(scope, oldState, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function PlayerSession:requestToSet(scope, action)
    return self.SetRequestPlayerSessionRF:InvokeServer(scope, action)
end

function PlayerSession:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function PlayerSession:Destroy()

end


return PlayerSession