local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Player.LocalSession.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Player.LocalSession.Signals

local LocalSessionData = require(script.Parent.LocalSessionData)

local PlayerLocalSession = {}
PlayerLocalSession.__index = PlayerLocalSession

function PlayerLocalSession.new(player)
    local self = {}
    setmetatable(self, PlayerLocalSession)
    self.player = player
    self._maid = Maid.new()
    self.localSession = LocalSessionData.getInitialSession()
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    return self
end

function PlayerLocalSession:get(scope)
    assert(self.localSession[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.localSession[scope]
end

function PlayerLocalSession:set(scope, action)
    -- Change state then use a copy for signals
    local state = TableUtils.deepCopy(Actions.apply(scope, self.localSession[scope], action))

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function PlayerLocalSession:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function PlayerLocalSession:Destroy()

end

return PlayerLocalSession