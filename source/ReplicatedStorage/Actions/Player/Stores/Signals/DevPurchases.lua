local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        setPurchaseCache = SignalE.new(),
        removeCache = SignalE.new(),
        updateRecordIdx = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        setPurchaseCache = {
            events.setPurchaseCache
        },
        removeCache = {
            events.removeCache
        },
        updateRecordIdx = {
            events.updateRecordIdx
        },
    }

    return signals
end

return module