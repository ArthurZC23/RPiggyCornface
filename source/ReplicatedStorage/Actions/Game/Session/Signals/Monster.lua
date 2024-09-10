local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        setNpcMonster = SignalE.new(),
        setPlayerMonster = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        setNpcMonster = {
            events.setNpcMonster,
        },
        setPlayerMonster = {
            events.setPlayerMonster,
        },
    }

    return signals
end

return module