local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        increment = SignalE.new(),
        decrement = SignalE.new(),
        reset = SignalE.new(),
        set = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        set = {
            events.set,
        },
        increment = {
            events.increment,
            events.set,
        },
        decrement = {
            events.decrement,
            events.set,
        },
        reset = {
            events.reset,
            events.set,
        },
    }

    return signals
end

return module