local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Char.Session.Actions)
local ActionSignals = Mod:find({"StateManager", "Actions", "Signals"})
local Signals = ReplicatedStorage.Actions.Char.Session.Signals

local RootF = script.Parent
local Components = {
    Replicator = require(RootF:WaitForChild("ReplicatorC")),
}

local CharSessionC = {}
CharSessionC.__index = CharSessionC
CharSessionC.className = "CharSession"

function CharSessionC.new(stateManager)
    -- print("[CharSessionC] 1")
    local self = {
        _maid = Maid.new(),
        stateManager = stateManager,
    }
    setmetatable(self, CharSessionC)

    if not self:initComponents() then return end

    -- print("[CharSessionC] 2")
    self.signals = self._maid:Add(ActionSignals.new(Signals))
    -- print("[CharSessionC] 3")
    self.replica = self.Replicator:getReplica()
    -- print("[CharSessionC] 4")

    if not self.stateManager.char.Parent then return end

    -- print("[CharSessionC] 5")

    return self
end

function CharSessionC:initComponents()
    for cName, cClass in pairs(Components) do
        local obj = cClass.new(self)
        if obj then
            self[cName] = self._maid:Add(obj)
        else
            return false
        end
    end
    return true
end

function CharSessionC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        -- Where should this remote be?
        getter=function()
            local RFs = ComposedKey.getFirstDescendant(self.player, {"Remotes", "Functions"})
            -- What is the correct name of the function?
            self.RequestReplicaRF = ComposedKey.getFirstDescendant(RFs, {"RequestPlayerSessionReplica"})
            return true
        end,
        keepTrying=function()

        end,
    })
    return ok
end

function CharSessionC:get(scope)
    assert(self.replica[scope] ~= nil, ("Scope %s is not valid."):format(scope))
    return self.replica[scope]
end

function CharSessionC:set(scope, action)
    local oldState = self:get(scope)
    local state = Actions.apply(scope, oldState, action)

    local signals = self.signals.bindedToAction[scope][action.name]
    for _, sig in ipairs(signals) do
        sig:Fire(state, action)
    end
end

function CharSessionC:getEvent(scope, eventName)
    return self.signals.events[scope][eventName]
end

function CharSessionC:Destroy()
    self._maid:Destroy()
end


return CharSessionC