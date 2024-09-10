local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        setMorph = SignalE.new(),
        setAge = SignalE.new(),
        setGender = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        setMorph = {
            events.setMorph,
        },
        setAge = {
            events.setAge,
        },
        setGender = {
            events.setGender,
        },
    }

    return signals
end

return module