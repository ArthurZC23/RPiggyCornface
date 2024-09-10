local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

-- Need to be a class because each player has its own signals
local ActionsSignals = {}
ActionsSignals.__index = ActionsSignals
ActionsSignals.className = "ActionsSignals"

function ActionsSignals.new(root)
    local self = {
        _maid = Maid.new(),
        events = {},
        bindedToAction = {},
    }
    setmetatable(self, ActionsSignals)
    local SignalsMods = self:loadModules(root)
    self:createSignals(SignalsMods)
    return self
end

function ActionsSignals:loadModules(root)
    local SignalsMods = {}
    for _, signalsMod in ipairs(root:GetChildren()) do
        SignalsMods[signalsMod.Name] = require(signalsMod)
    end
    return SignalsMods
end

function ActionsSignals:createSignals(SignalsMods)
    for name, mod in pairs(SignalsMods) do
        local signals = mod.createSignals()
        self.events[name] = signals.events
        self.bindedToAction[name] = signals.bindedToAction
    end
end

function ActionsSignals:Destroy()
    self._maid:Destroy()
end

return ActionsSignals