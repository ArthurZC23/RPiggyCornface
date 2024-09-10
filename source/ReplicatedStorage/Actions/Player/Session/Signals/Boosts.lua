local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        enableBoost = SignalE.new(),
        disableBoost = SignalE.new(),
        toggleBoost = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        enableBoost = {
            events.enableBoost,
            events.toggleBoost,
        },
        disableBoost = {
            events.disableBoost,
            events.toggleBoost,
        },
    }

    return signals
end

return module