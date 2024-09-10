local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addCriticalTimestamp = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addCriticalTimestamp = {
            events.addCriticalTimestamp
        },
    }

    return signals
end

return module