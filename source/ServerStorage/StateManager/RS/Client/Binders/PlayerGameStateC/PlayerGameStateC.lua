local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})

local RootFolder = script.Parent
local StateTypes = {
    Session = require(RootFolder:WaitForChild("PlayerGameSession"):WaitForChild("PlayerGameSessionC")),
}

local localPlayer = Players.LocalPlayer

local PlayerGameStateC = {}
PlayerGameStateC.__index = PlayerGameStateC
PlayerGameStateC.className = "PlayerGameState"
PlayerGameStateC.TAG_NAME = PlayerGameStateC.className

local StateTypesServer = require(ComposedKey.getAsync(ReplicatedStorage, {
    "StateManager", "Shared", "GameState", "StateTypesServer"}
))

function PlayerGameStateC.new(player)
    if player ~= localPlayer then return end
    local self = {}
    setmetatable(self, PlayerGameStateC)
    self._maid = Maid.new()

    self._stateTypes = {}
    for _, stateType in ipairs(StateTypesServer.array) do
        self._stateTypes[stateType] = self._maid:Add(StateTypes[stateType].new(self))
    end

    return self
end

function PlayerGameStateC:get(stateType, scope)
    return self._stateTypes[stateType]:get(scope)
end

function PlayerGameStateC:sync(stateType, scope, action)
    self._stateTypes[stateType]:sync(scope, action)
end

function PlayerGameStateC:requestToSet(stateType, scope, action)
    return self._stateTypes[stateType]:requestToSet(scope, action)
end

function PlayerGameStateC:getEvent(stateType, scope, eventName)
    return self._stateTypes[stateType]:getEvent(scope, eventName)
end

function PlayerGameStateC:Destroy()
    self._maid:Destroy()
end

return PlayerGameStateC