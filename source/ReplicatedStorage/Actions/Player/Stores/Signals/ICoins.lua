local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addUnlockHairCoin = SignalE.new(),
        removeUnlockHairCoin = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addUnlockHairCoin = {
            events.addUnlockHairCoin,
        },
        removeUnlockHairCoin = {
            events.removeUnlockHairCoin,
        },
    }

    return signals
end

return module