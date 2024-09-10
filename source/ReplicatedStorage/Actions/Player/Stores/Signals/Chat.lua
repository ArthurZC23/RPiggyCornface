local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        addTag = SignalE.new(),
        editTag = SignalE.new(),
        removeTag = SignalE.new(),
        equipTag = SignalE.new(),
        setBubble = SignalE.new(),
        mute = SignalE.new(),
        unmute = SignalE.new(),
        setMute = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        addTag = {
            events.addTag,
        },
        editTag = {
            events.editTag,
        },
        removeTag = {
            events.removeTag,
        },
        equipTag = {
            events.equipTag,
        },
        setBubble = {
            events.setBubble,
        },
        mute = {
            events.mute,
            events.setMute,
        },
        unmute = {
            events.unmute,
            events.setMute,
        },
    }

    return signals
end

return module