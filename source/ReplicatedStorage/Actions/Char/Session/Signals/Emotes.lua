local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        startEmote = SignalE.new(),
        stopEmote = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        startEmote = {
            events.startEmote,
        },
        stopEmote = {
            events.stopEmote,
        },
    }

    return signals
end

return module