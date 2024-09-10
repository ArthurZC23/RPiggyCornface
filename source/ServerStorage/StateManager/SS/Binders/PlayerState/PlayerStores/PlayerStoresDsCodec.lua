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

local RootF = script:FindFirstAncestor("PlayerStoresDsCodec")
local FixStoresStates = require(RootF:WaitForChild("FixStoresStates"))

local DsbStores = Data.DataStore.DsbStores
local DsbConfig = Data.DataStore.DsbConfig

local PlayerStoresDsCodec = {}
PlayerStoresDsCodec.__index = PlayerStoresDsCodec

PlayerStoresDsCodec.stateType = "Stores"

function PlayerStoresDsCodec.new(playerStores)
    local self = {
        playerStores = playerStores,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerStoresDsCodec)
    return self
end

function PlayerStoresDsCodec:encode(state, scope)

end

function PlayerStoresDsCodec:decode(state, scope)

end

function PlayerStoresDsCodec:Destroy()
    self._maid:Destroy()
end

return PlayerStoresDsCodec