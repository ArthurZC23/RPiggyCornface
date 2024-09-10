local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Mts = Mod:find({"Table", "Mts"})

local RootFolder = script.Parent
local PlayerLocalSession = require(RootFolder.PlayerLocalSession.PlayerLocalSessionC)
local PlayerSession = require(RootFolder.PlayerSession.PlayerSessionC)
local PlayerStores = require(RootFolder.PlayerStores.PlayerStoresC)

local localPlayer = Players.LocalPlayer

local PlayerState = {}
PlayerState.__index = PlayerState
PlayerState.className = "PlayerState"
PlayerState.TAG_NAME = PlayerState.className

PlayerState.StateTypes = Mts.makeEnum("PlayerStateTypes", {
    ["LocalSession"]="LocalSession",
    ["Session"]="Session",
    ["Stores"]="Stores",
})

function PlayerState.new(player)
    if localPlayer ~= player then return end
    local self = {
        player = player,
    }
    setmetatable(self, PlayerState)
    self._maid = Maid.new()

    self._stateTypes = {
        [PlayerState.StateTypes.Stores] = self._maid:Add(PlayerStores.new(player)),
        [PlayerState.StateTypes.Session] = self._maid:Add(PlayerSession.new(player)),
        [PlayerState.StateTypes.LocalSession] = self._maid:Add(PlayerLocalSession.new(player)),
    }

    return self
end

function PlayerState:get(stateType, scope)
    return self._stateTypes[stateType]:get(scope)
end

function PlayerState:set(stateType, scope, action)
    if stateType == PlayerState.StateTypes.LocalSession then
        local kwargs = self._stateTypes[stateType]:set(scope, action)
        return kwargs
    else
        error(("Cannot set state %s from client."):format(stateType))
    end
end

function PlayerState:sync(stateType, scope, action)
    self._stateTypes[stateType]:sync(scope, action)
end

function PlayerState:requestToSet(stateType, scope, action)
    return self._stateTypes[stateType]:requestToSet(scope, action)
end

function PlayerState:getEvent(stateType, scope, eventName)
    return self._stateTypes[stateType]:getEvent(scope, eventName)
end

function PlayerState:Destroy()
    self._maid:Destroy()
end

return PlayerState