local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        playAction1Animation = SignalE.new(),
        stopAction1Animation = SignalE.new(),
        setAction1Animation = SignalE.new(),
        playAction2Animation = SignalE.new(),
        stopAction2Animation = SignalE.new(),
        setAction2Animation = SignalE.new(),
        playIdleAnimation = SignalE.new(),
        stopIdleAnimation = SignalE.new(),
        setIdleAnimation = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        playAction1Animation = {
            events.playAction1Animation,
            events.setAction1Animation,
        },
        stopAction1Animation = {
            events.stopAction1Animation,
            events.setAction1Animation,
        },
        playAction2Animation = {
            events.playAction2Animation,
            events.setAction2Animation,
        },
        stopAction2Animation = {
            events.stopAction2Animation,
            events.setAction2Animation,
        },
        playIdleAnimation = {
            events.playIdleAnimation,
            events.setIdleAnimation,
        },
        stopIdleAnimation = {
            events.stopIdleAnimation,
            events.setIdleAnimation,
        },
    }


    return signals
end

return module