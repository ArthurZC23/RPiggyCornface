local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})
local Data = Mod:find({"Data", "Data"})

local RootF = script:FindFirstAncestor("Signals").Parent
local CascadingSignals = require(RootF.CascadingSignals.Regions)

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        AddRegions = SignalE.new(),
        RemoveRegions = SignalE.new(),
        SetRegions = SignalE.new(),

        Props = SignalE.new(),
        PlaySoundtrack = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        AddRegions = {
            events.AddRegions,
            events.SetRegions,
        },
        RemoveRegions = {
            events.RemoveRegions,
            events.SetRegions,
        },
    }

    for cbName, cb in pairs(CascadingSignals.callbacks) do
        local event = events[cbName]
        event.Fire = function(self, state, action)
            SignalE.Fire(self, state, action)
            cb(state, action, events)
        end
    end

    return signals
end

return module