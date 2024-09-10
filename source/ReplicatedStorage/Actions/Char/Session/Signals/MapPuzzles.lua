local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addKey = SignalE.new(),
        removeKey = SignalE.new(),
        resetKeys = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addKey = {
            events.addKey,
        },
        removeKey = {
            events.removeKey,
        },
        resetKeys = {
            events.resetKeys,
        },
    }

    return signals
end

return module