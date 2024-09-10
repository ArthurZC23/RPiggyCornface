local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})

local BigNotificationGuiRE = ReplicatedStorage.Remotes.Events:WaitForChild("BigNotificationGui")

local DataStoreB = require(ServerStorage.DataStoreB)
local Data = Mod:find({"Data", "Data"})
local InitialStoresStateData = Data.InitialState.Stores
local GameAnalytics = require(ServerStorage.GameAnalytics)

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Player.Stores.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Player.Stores.Signals

local Replicator = require(script.Parent.Replicator)
local ClientRequests = require(script.Parent.ClientRequests)

local RootF = script:FindFirstAncestor("PlayerStores")
local FixStoresStates = require(RootF:WaitForChild("FixStoresStates"))

local DsbStores = Data.DataStore.DsbStores
local DsbConfig = Data.DataStore.DsbConfig

local PlayerStores = {}
PlayerStores.__index = PlayerStores

PlayerStores.stateType = "Stores"

function PlayerStores.new(playerState)
    local self = {
        playerState = playerState,
        player = playerState.player,
        _maid = Maid.new(),
        isStateTypeReplicated = false,
    }
    setmetatable(self, PlayerStores)
    self.stores, self.dSstores = self:loadStores()
    self:loadStudioState()
    self:fixState(self.stores)
    self.initialReplica = self:getStoresStateCopy()
    self._replicator = self._maid:Add(Replicator.new(self))
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    self._clientRequests = self._maid:Add(ClientRequests.new(self))
    return self
end

function PlayerStores:fixState(stores)
    FixStoresStates.fixStates(stores)
end

function PlayerStores:loadStudioState()
    --print("1111111111")
    if not RunService:IsStudio() then return end
    if game.PlaceId ~= 0 then return end

    local dSstores = self.dSstores
    local initialState =
        InitialStoresStateData.studio[tostring(self.player.UserId)]
        or {}

    TableUtils.setProto(initialState, InitialStoresStateData.studio["Proto"])

    for scope, store in pairs(dSstores) do
        local newState = initialState[scope]
        if not newState then continue end
        -- local state = self:get(scope)
        -- TableUtils.setTable(state, newState)
        self.stores[scope] = newState
        store:Set(newState)
    end
    --print("2222222222")
end

-- function PlayerStores:getStoreState()
--     local stores = {}
--     for storeName, _ in pairs(self.stores) do
--         stores[storeName] = self:get(storeName)
--     end
--     return stores
-- end

function PlayerStores:loadStores()
    --print("Load Stores")
    local stores = {}
    local dSstores = {}

    local attempts = DsbConfig.backupValues.getAttempts
    local cooldown = DsbConfig.backupValues.cooldown
    for scope, _ in pairs(DsbStores.names) do
        dSstores[scope] = DataStoreB(DsbStores.names[scope], self.player)
        dSstores[scope]:SetBackup(attempts, cooldown)
        stores[scope] = dSstores[scope]:GetTable(DsbStores.default[scope])
    end

    -- load data
    local scope = next(DsbStores.names)
    if scope and game.PlaceId ~= 0 then
        local dSstore = dSstores[scope]
        -- Load data to the game and set backup
        -- I think this could be refactored to be included in the loop above.
        dSstore:GetTable(DsbStores.default[scope])

        if dSstore.backup then
            self.backup = true
            BigNotificationGuiRE:FireClient(
                self.player,
                "Roblox DataStore failed to return your data. This game session will not save any new data. You should rejoin to try to load your data again!",
                15
            )
        end
    end
    return stores, dSstores
end

function PlayerStores:getStoresStateCopy()
    return TableUtils.deepCopy(self.stores)
end

function PlayerStores:isStateBackup()
    return self.backup
end

function PlayerStores:get(scope)
    assert(self.stores[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return TableUtils.deepCopy(self.stores[scope]) -- This is a deep copy
end

function PlayerStores:set(scope, action)
    -- local oldState = self:get(scope)
    -- local state = Actions.apply(scope, oldState, action) -- state worked on the deep copy

    -- This first line cannot be "state" because some actions could assign a new table to the variable instead of changing the existing table.
    self.stores[scope] = Actions.apply(scope, self.stores[scope], action)
    local stateCopy = TableUtils.deepCopy(self.stores[scope])

    -- This is a problem because if Fire triggers another action, it's replication will go faster than
    -- the one in replicator. My tmp solution was to replicate before signals were applied.
    -- The real solution is making a job queue.

    self._replicator:sync(scope, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        -- State will always be correct, even if a new action is applied. This is just a snapshot of the state.
        sig:Fire(stateCopy, action)
    end

    if action._ga then
        local _ga = action._ga
        GameAnalytics[_ga.addEvent](GameAnalytics, _ga.eventScope, _ga.kwargs)
    end

    -- Maybe this should be in a job queue
    local store = DataStoreB(DsbStores.names[scope], self.player)
    store:Set(self.stores[scope]) -- Store state is a deep copy of state
end

function PlayerStores:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function PlayerStores:saveData(retries, cooldown)
    retries = retries or 1
    cooldown = cooldown or 3

    local function _save()
        return Promise.new(function (resolve, reject)
            local ok, err = pcall(DataStoreB.SaveAll, self.player)
            if ok then
                resolve()
            else
                Cronos.wait(cooldown)
                reject(tostring(err))
            end
        end)
    end

    return Promise.retry(_save, retries)
        :catch(function (err)
            local errMsg = (
                "Could not save player %s %s data.\n"
                .."Error: %s"):format(
                self.player.Name,
                self.player.UserId,
                tostring(err)
            )
            warn(errMsg)
            GameAnalytics:addErrorEvent(self.player.UserId, {
                severity = GameAnalytics.EGAErrorSeverity.error,
                message = errMsg
            })
            error(errMsg)
        end)
end

function PlayerStores:Destroy()
    -- Maybe need to set self.stores to nil
    self._maid:Destroy()
end


return PlayerStores