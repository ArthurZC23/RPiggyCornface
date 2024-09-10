local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SignalE = Mod:find({"Signal", "Event"})
local Data = Mod:find({"Data", "Data"})
local InitialGameSessionState = Data.InitialState.GameSession
local TableUtils = Mod:find({"Table", "Utils"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Game.Session.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Game.Session.Signals

local GameSessionData = require(script.Parent.GameSessionData.GameSessionData)

local GameSession = {}
GameSession.__index = GameSession
GameSession.className = "GameSession"

function GameSession.new(gameState)
    local self = {}
    setmetatable(self, GameSession)
    self.gameState = gameState
    self._maid = Maid.new()
    self.states = GameSessionData.getInitialSession()
    self:loadStudioState()
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    self.allSignal = self._maid:Add(SignalE.new())
    return self
end

function GameSession:loadStudioState()
    if not RunService:IsStudio() then return end
    if game.PlaceId ~= 0 then return end

    local initialState = {}
    TableUtils.setProto(initialState, InitialGameSessionState.studio["Proto"])

    for scope in pairs(self.states) do
        local newState = initialState[scope]
        if not newState then continue end
        self.states[scope] = newState
    end
end

function GameSession:get(scope)
    assert(self.states[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.states[scope]
end

function GameSession:set(scope, action)
    local state = Actions.apply(scope, self.states[scope], action)

    -- Need replication here!
    -- This is used to register game states to player game state replicators
    self.allSignal:Fire(scope, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function GameSession:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function GameSession:getAllEvents()
    return self.allSignal
end

function GameSession:Destroy()

end

return GameSession