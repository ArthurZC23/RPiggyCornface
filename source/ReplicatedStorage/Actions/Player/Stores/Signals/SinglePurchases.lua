local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        startSinglePurchase = SignalE.new(),
        finishSinglePurchase = SignalE.new(),
        addDetails = SignalE.new(),
        removeSinglePurchase = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        startSinglePurchase = {
            events.startSinglePurchase,
        },
        finishSinglePurchase = {
            events.finishSinglePurchase,
        },
        addDetails = {
            events.addDetails,
        },
        removeSinglePurchase = {
            events.removeSinglePurchase,
        },
    }

    return signals
end

return module