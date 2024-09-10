local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addDb = SignalE.new(),
        removeDb = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addDb = {
            events.addDb
        },
        removeDb = {
            events.removeDb
        },
    }

    return signals
end

return module