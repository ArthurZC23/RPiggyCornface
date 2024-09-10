local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        viewTab = SignalE.new(),
        setTab = SignalE.new(),
        reset = SignalE.new(),
        addToAssetCache = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        viewTab = {
            events.viewTab,
        },
        setTab = {
            events.setTab,
        },
        reset = {
            events.reset,
        },
        addToAssetCache = {
            events.addToAssetCache,
        },
    }

    return signals
end

return module