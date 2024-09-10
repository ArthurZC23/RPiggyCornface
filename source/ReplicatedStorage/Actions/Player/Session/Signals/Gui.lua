local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        request = SignalE.new(),
        setPurchaseState = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        request = {
            events.request,
        },
        setPurchaseState = {
            events.setPurchaseState,
        },
    }

    return signals
end

return module