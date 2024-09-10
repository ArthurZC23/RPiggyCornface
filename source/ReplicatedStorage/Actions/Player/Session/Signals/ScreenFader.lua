local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        fadeIn = SignalE.new(),
        fadeOut = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        fadeIn = {
            events.fadeIn
        },
        fadeOut = {
            events.fadeOut
        },
    }

    return signals
end

return module