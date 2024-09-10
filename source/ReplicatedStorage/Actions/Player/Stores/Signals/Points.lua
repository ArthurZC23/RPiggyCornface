local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        Increment = SignalE.new(),
        Decrement = SignalE.new(),
        Update = SignalE.new(),
        IncrementRate = SignalE.new(),
        SetRate = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        Increment = {
            events.Increment,
            events.Update
        },
        Decrement = {
            events.Decrement,
            events.Update,
        },
        IncrementRate = {
            events.IncrementRate,
        },
        SetRate = {
            events.SetRate,
        },
    }

    return signals
end

return module