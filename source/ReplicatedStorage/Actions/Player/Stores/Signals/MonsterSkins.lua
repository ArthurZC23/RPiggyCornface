local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        eq = SignalE.new(),
        add = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        eq = {
            events.eq
        },
        add = {
            events.add
        },
    }

    return signals
end

return module