local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        add = SignalE.new(),
        remove = SignalE.new(),
        setPreviousLifeCache = SignalE.new(),
        setSyncCacheFlag = SignalE.new(),
        update = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        add = {
            events.add,
            events.update,
        },
        remove = {
            events.remove,
            events.update,
        },
        setPreviousLifeCache = {
            events.setPreviousLifeCache,
        },
        setSyncCacheFlag = {
            events.setSyncCacheFlag,
        },
    }

    return signals
end

return module