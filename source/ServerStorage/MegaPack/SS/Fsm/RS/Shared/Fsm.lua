local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local TableUtils = Mod:find({"Table", "Utils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local FireFilteredClients = Mod:find({"Remotes", "FireFilteredClients"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local SharedFolder = script:FindFirstAncestor("Shared")
local Transition = require(ComposedKey.getAsync(SharedFolder, {"Transition"}))

local Fsm = {}
Fsm.__index = Fsm

function Fsm.new(kwargs)
    kwargs = kwargs or {}
    local self = {
        kwargs = kwargs,
        lastMethodWasExit = false,
        debug_ = kwargs.debug_ or false,
        _currentState = nil,
        _transitions = {},
        _anyTransitions = {},
        _currentTransitions = {},
        _emptyTransitions = {},
        dataContainer = {},
    }
	setmetatable(self, Fsm)

    if kwargs.sync then
        local syncEventName = ("FsmSync%s"):format(kwargs.sync.syncName)
        local syncFunctionName = ("FsmInitialSync%s"):format(kwargs.sync.syncName)
        self:createRemotes(kwargs.sync.syncedInst, syncEventName, syncFunctionName)
        self:createSignals(kwargs.sync.syncedInst, syncEventName)
    end

    self.update = Debounce.standard(self.update)
    return self
end

function Fsm:createRemotes(syncedInst, syncEventName, syncFunctionName)
    local eventsNames = {syncEventName}
    local functionsNames = {syncFunctionName}
    GaiaServer.createRemotes(syncedInst, {
        events = eventsNames,
        functions = functionsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        self[("%sRE"):format(eventName)] = syncedInst.Remotes.Events[eventName]
    end
    for _, funcName in ipairs(functionsNames) do
        self[("%sRF"):format(funcName)] = syncedInst.Remotes.Functions[funcName]
    end
end

function Fsm:handleSyncEventRF()
    self.syncEventRF.OnServerInvoke = function()
        return self.lastPayload
    end
end

function Fsm:createSignals(syncedInst, syncEventName)
    local eventsNames = {syncEventName}
    return self._maid:Add(GaiaShared.createBinderSignals(self, syncedInst, {
        events = eventsNames,
    }))
end

function Fsm:createConfig(configProto, states)
    local config = TableUtils.deepCopy(configProto)
    for _, tData in ipairs(config.transitions) do
        tData.kwargs.from = states[tData.kwargs.from]
        tData.kwargs.to = states[tData.kwargs.to]
    end

    self.states = states

    if self.kwargs.sync then
        self:addSyncCallback(states)
    end
    return config
end

function Fsm:addSyncCallback(states)
    for stateName, stateObj in pairs(states) do
        local stateMethods = {"onEnter", "update", "onExit"}
        for _, methodName in ipairs(stateMethods) do
            local method = stateObj[methodName]
            stateObj[methodName] = function()
                -- print("Test Fsm Decorator")
                local hasSynced = false
                local function syncCallback(kwargsRE, kwargsSE)
                    local payloadRE = {
                        stateName = stateName,
                        methodName = methodName,
                        kwargs = kwargsRE,
                    }
                    local payloadSE = {
                        stateName = stateName,
                        methodName = methodName,
                        kwargs = kwargsSE,
                    }
                    self:sync(payloadRE, payloadSE)
                    self.lastPayload = payloadRE
                    hasSynced = true
                end
                method(stateObj, syncCallback)
                if not hasSynced then
                    syncCallback({}, {})
                end
            end
            -- stateObj[method] = function(...)
            --     print("Test Fsm Decorator")
            --     local result = stateObj[method](...)
            --     result = result or {}
            --     local payloadRE = {
            --         stateName = stateName,
            --         method = method,
            --         kwargs = result.kwargsSyncRE,
            --     }
            --     local payloadSE = {
            --         stateName = stateName,
            --         method = method,
            --         kwargs = result.kwargsSyncSE,
            --     }
            --     if self.kwargs.sync.replicateTo == "All" then
            --         self.SyncRE:FireAllClients(payloadRE)
            --     elseif self.kwargs.sync.replicateTo == "playerAndFriends" then
            --         local playerState = self.kwargs.sync.playerState
            --         if not playerState.isDestroyed then
            --             FireFilteredClients.playerAndFriends(playerState, self.SyncRE, payloadRE)
            --         end
            --     elseif self.kwargs.sync.replicateTo == "friends" then
            --         local playerState = self.kwargs.sync.playerState
            --         if not playerState.isDestroyed then
            --             FireFilteredClients.friends(playerState, self.SyncRE, payloadRE)
            --         end
            --     elseif self.kwargs.sync.replicateTo == "others" then
            --         local player = self.kwargs.sync.player
            --         FireFilteredClients.others(player, self.SyncRE, payloadRE)
            --     else
            --         error(("replicateTo %s is not valid."):format(self.kwargs.sync.replicateTo))
            --     end
            --     self.SyncSE:Fire(payloadSE)
            -- end
        end
    end
end

function Fsm:sync(payloadRE, payloadSE)
    self:syncRemote(payloadRE)
    self:syncSignal(payloadSE)
end

function Fsm:syncRemote(payload)
    local replicateTo = self.kwargs.sync.replicateTo
    if replicateTo == "All" then
        self.syncEventRE:FireAllClients(payload)
    elseif replicateTo == "player" then
        local player = self.kwargs.sync.player
        self.syncEventRE:FireClient(player, payload)
    elseif replicateTo == "playerAndFriends" then
        local playerState = self.kwargs.sync.playerState
        if not playerState.isDestroyed then
            FireFilteredClients.playerAndFriends(playerState, self.syncEventRE, payload)
        end
    elseif replicateTo == "friends" then
        local playerState = self.kwargs.sync.playerState
        if not playerState.isDestroyed then
            FireFilteredClients.friends(playerState, self.syncEventRE, payload)
        end
    elseif replicateTo == "others" then
        local player = self.kwargs.sync.player
        FireFilteredClients.others(player, self.syncEventRE, payload)
    else
        error(("replicateTo %s is not valid."):format(replicateTo))
    end
end

function Fsm:syncSignal(payload)
    self.syncEventSE:Fire(payload)
end

function Fsm:config(data)
	for _, tData in ipairs(data.transitions) do self[tData.method](self, tData.kwargs) end
end

function Fsm:update(kwargs)
    if self.isDestroyed then return end
    local transition = self:getTransition()
	if transition then
		if self.debug_ then
			print(("Transition from %s to %s"):format(transition.from.className, transition.to.className))
		end

        self:_applyTransition(transition)
    end
    if self.isDestroyed then return end
    self._currentState:update(kwargs)
end

function Fsm:_applyTransition(transition)
	transition:onBeforeTransition(self.dataContainer)
    if self.isDestroyed then return end
    self:setState(transition.to)
    if self.isDestroyed then return end
	transition:onAfterTransition(self.dataContainer)
end

function Fsm:setState(state)
	-- Doesn't allow to reenter a state. This is not correct.
    --if state == self._currentState then
    --    return
    --end
    if self._currentState then self._currentState:onExit() end
    self.lastMethodWasExit = true
    if self.isDestroyed then return end
    self._currentState = state
    self._currentTransitions = self._transitions[state] or self._emptyTransitions
    self._currentState:onEnter()
    self.lastMethodWasExit = false
end

function Fsm:recordFsmState(stateName, stateMethod)
    self.fsmState = {
        stateName = stateName,
        stateMethod = stateMethod,
    }
end

function Fsm:addMultipleTransitions(kwargs)
	for i, from in ipairs(kwargs.fromArray) do
		for j, to in ipairs(kwargs.toArray) do
			local transitionName = ("%s_%s_%s"):format(kwargs.name, i, j)
			self:addTransition(transitionName, from, to, kwargs.condition, kwargs.onBeforeTransition, kwargs.onAfterTransition)
		end
	end
end

function Fsm:addTransition(kwargs)
	if not self._transitions[kwargs.from] then
		self._transitions[kwargs.from] = {}
    end
	table.insert(self._transitions[kwargs.from], Transition.new(
		kwargs.name, kwargs.from, kwargs.to, kwargs.condition, kwargs.onBeforeTransition, kwargs.onAfterTransition))
end

function Fsm:addAnyTransition(kwargs)
	table.insert(self._anyTransitions, Transition.new(
		kwargs.name, "All", kwargs.to, kwargs.condition, kwargs.onBeforeTransition, kwargs.onAfterTransition))
end

function Fsm:addAllTransition(kwargs)
	-- Need to implement
end

function Fsm:getCurrentState()
	return self._currentState.className
end

function Fsm:getTransition()
    for _, transition in ipairs(self._anyTransitions) do
		if (transition:verifyCondition(self.dataContainer)) then
            return transition
        end
    end
    for _, transition in ipairs(self._currentTransitions) do
		if (transition:verifyCondition(self.dataContainer)) then
            return transition
        end
    end
end

function Fsm:Destroy()
    if self._currentState and not(self.lastMethodWasExit) then
        self._currentState:onExit()
    end
    for _, stateObj in pairs(self.states) do
        stateObj:Destroy()
    end
    self.isDestroyed = true
end

return Fsm