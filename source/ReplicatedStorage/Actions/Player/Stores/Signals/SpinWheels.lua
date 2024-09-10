local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addSpin = SignalE.new(),
        useSpin = SignalE.new(),
        startSpinTimer = SignalE.new(),
        reset = SignalE.new(),
        --------------------------
        changeSpinCount = SignalE.new(),
        stopTimer = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addSpin = {
            events.addSpin,
            events.changeSpinCount,
            events.stopTimer,
        },
        useSpin = {
            events.useSpin,
            events.changeSpinCount,
        },
        startSpinTimer = {
            events.startSpinTimer,
        },
        reset = {
            events.reset,
            events.changeSpinCount,
            events.stopTimer,
        },
    }

    return signals
end

return module