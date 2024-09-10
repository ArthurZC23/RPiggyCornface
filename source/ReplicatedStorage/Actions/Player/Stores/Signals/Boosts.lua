local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addBoost = SignalE.new(),
        removeBoost = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addBoost = {
            events.addBoost
        },
        removeBoost = {
            events.removeBoost
        },
    }

    return signals
end

return module