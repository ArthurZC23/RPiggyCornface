local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Char.Session.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Char.Session.Signals

local Replicator = require(script.Parent.Replicator)
local SessionData = require(script.Parent.CharSessionData.CharSessionData)

local CharSession = {}
CharSession.className = "CharSession"
CharSession.__index = CharSession

function CharSession.new(stateManager)
    local self = {
        stateManager = stateManager,
        _maid = Maid.new(),
        session = SessionData.getInitialSession(stateManager),
    }
    setmetatable(self, CharSession)
    self:loadStudioState()
    self.initialReplica = self:getSessionStateCopy()
    self._replicator = self._maid:Add(Replicator.new(self))
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    return self
end

local RunService = game:GetService("RunService")
local Data = Mod:find({"Data", "Data"})
local InitialSessionStateData = Data.InitialState.CharSession
function CharSession:loadStudioState()
    if not RunService:IsStudio() then return end
    if game.PlaceId ~= 0 then return end
    local initialState =
        TableUtils.deepCopy(InitialSessionStateData.studio[tostring(self.stateManager.player.UserId)])
        or {}

    TableUtils.setProto(initialState, InitialSessionStateData.studio["Proto"])

    for scope in pairs(self.session) do
        local newState = initialState[scope]
        if not newState then continue end
        self.session[scope] = newState
    end
end

function CharSession:getSessionStateCopy()
    return TableUtils.deepCopy(self.session)
end

function CharSession:get(scope)
    assert(self.session[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.session[scope]
end

function CharSession:set(scope, action)
    self.session[scope] = Actions.apply(scope, self.session[scope], action)
    local stateCopy = TableUtils.deepCopy(self.session[scope])

    self._replicator:sync(scope, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(stateCopy, action)
    end
end

function CharSession:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function CharSession:Destroy()
    self._maid:Destroy()
end

return CharSession