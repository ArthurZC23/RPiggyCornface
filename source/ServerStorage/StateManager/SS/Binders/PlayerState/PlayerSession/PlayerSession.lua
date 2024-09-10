local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Player.Session.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Player.Session.Signals

local ClientRequests = require(script.Parent.ClientRequests)
local Replicator = require(script.Parent.Replicator)
local SessionData = require(script.Parent.SessionData.SessionData)

local PlayerSession = {}
PlayerSession.__index = PlayerSession

function PlayerSession.new(playerState)
    local self = {}
    setmetatable(self, PlayerSession)
    self.playerState = playerState
    self.player = playerState.player
    self._maid = Maid.new()
    self.session = SessionData.getInitialSession(playerState)
    self:loadStudioState()
    self.initialReplica = self:getSessionStateCopy()
    self._replicator = self._maid:Add(Replicator.new(self))
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    self._clientRequests = self._maid:Add(ClientRequests.new(self))
    return self
end

local Data = Mod:find({"Data", "Data"})
local InitialSessionStateData = Data.InitialState.Session
local RunService = game:GetService("RunService")
function PlayerSession:loadStudioState()
    if not RunService:IsStudio() then return end
    if game.PlaceId ~= 0 then return end
    local initialState =
        InitialSessionStateData.studio[tostring(self.player.UserId)]
        or {}

    TableUtils.setProto(initialState, InitialSessionStateData.studio["Proto"])

    for scope in pairs(self.session) do
        local newState = initialState[scope]
        if not newState then continue end
        self.session[scope] = newState
    end
end

function PlayerSession:getSessionStateCopy()
    return TableUtils.deepCopy(self.session)
end

function PlayerSession:get(scope)
    assert(self.session[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.session[scope]
end

function PlayerSession:set(scope, action)
    self.session[scope] = Actions.apply(scope, self.session[scope], action)
    local stateCopy = TableUtils.deepCopy(self.session[scope])

    self._replicator:sync(scope, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(stateCopy, action)
    end
end

function PlayerSession:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function PlayerSession:Destroy()
    -- Maybe need to set self.session to nil
    self._maid:Destroy()
end

return PlayerSession