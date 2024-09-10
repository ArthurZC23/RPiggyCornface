local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addDevProduct = SignalE.new(),
        addGp = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addDevProduct = {
            events.addDevProduct,
        },
        addGp = {
            events.addGp,
        },
    }

    return signals
end

return module