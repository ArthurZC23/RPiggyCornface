local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        add = SignalE.new(),
        remove = SignalE.new(),
        update = SignalE.new(),
        reset = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        add = {
            events.add,
            events.update,
        },
        remove = {
            events.remove,
            events.update,
        },
        reset = {
            events.reset,
            events.update,
        },
    }

    return signals
end

return module