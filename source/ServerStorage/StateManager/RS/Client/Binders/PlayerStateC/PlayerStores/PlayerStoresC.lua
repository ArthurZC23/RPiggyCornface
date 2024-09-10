local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
-- local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Player.Stores.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Player.Stores.Signals

local PlayerStores = {}
PlayerStores.__index = PlayerStores

PlayerStores.stateType = "Stores"

function PlayerStores.new(player)
    local self = {}
    setmetatable(self, PlayerStores)
    self.player = player

    self._maid = Maid.new()

    --self.scheduler = JobScheduler.new(function(job) self:_sync(unpack(job)) end)
    self.actionsQueue = {}

    local RFs = self.player
        :WaitForChild("Remotes")
        :WaitForChild("Functions")

    self.SetRequestPlayerStoresRF = RFs:WaitForChild("SetRequestPlayerStores")
    self.RequestPlayerStoresReplicaRF = RFs:WaitForChild("RequestPlayerStoresReplica")

    self.replica = self:getReplica()
    self.signals = self._maid:Add(ActionSignals.new(Signals))

    -- In case player left during yield. Binder _add leaves and is as if the tag never existed.
    if not self.player.Parent then
        return
    end

    return self
end

function PlayerStores:getReplica()
    local replica = self.RequestPlayerStoresReplicaRF:InvokeServer()
    self._isStateLoaded = true
    for _, data in ipairs(self.actionsQueue) do
        self:_sync(unpack(data))
    end
    self.actionsQueue = nil
    return replica
end

function PlayerStores:get(scope)
    assert(self.replica[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.replica[scope]
end

function PlayerStores:sync(scope, action)
    if self._isStateLoaded then
        self:_sync(scope, action)
    else
        table.insert(self.actionsQueue, {scope, action})
        --self.scheduler:pushJob({scope, action})
    end
end

function PlayerStores:_sync(scope, action)
    local oldState = self:get(scope)
    local state = Actions.apply(scope, oldState, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function PlayerStores:requestToSet(scope, action)
    return self.SetRequestPlayerStoresRF:InvokeServer(scope, action)
end

function PlayerStores:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function PlayerStores:Destroy()

end


return PlayerStores