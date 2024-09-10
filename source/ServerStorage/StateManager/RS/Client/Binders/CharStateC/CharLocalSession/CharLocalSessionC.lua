local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Char.LocalSession.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Char.LocalSession.Signals

local RootF = script.Parent
local LocalSessionData = require(RootF:WaitForChild("LocalSessionData"))

local CharLocalSessionC = {}
CharLocalSessionC.__index = CharLocalSessionC

function CharLocalSessionC.new(stateManager)
    -- print("[CharLocalSessionC] 1")
    local self = {
        stateManager = stateManager,
        _maid = Maid.new()
    }
    setmetatable(self, CharLocalSessionC)

    self.localSession = LocalSessionData.getInitialSession()
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    -- print("[CharLocalSessionC] 2")
    return self
end

function CharLocalSessionC:get(scope)
    assert(self.localSession[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.localSession[scope]
end

function CharLocalSessionC:set(scope, action)
    local state = TableUtils.deepCopy(Actions.apply(scope, self.localSession[scope], action))

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function CharLocalSessionC:sync(scope, action)
    error("No sync implemented.")
end

function CharLocalSessionC:requestToSet(scope, action)
    error("No requestToSet implemented.")
end

function CharLocalSessionC:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function CharLocalSessionC:Destroy()

end

return CharLocalSessionC