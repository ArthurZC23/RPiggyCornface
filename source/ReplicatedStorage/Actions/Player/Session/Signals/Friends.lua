local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})

local module = {}

function module.createSignals()
    local signals = {}

    signals.events = {
        SetInGameFriendType = SignalE.new(),
        RemoveInGameFriend = SignalE.new(),
        UpdateNumberFriends = SignalE.new(),
    }

    local events = signals.events

    signals.bindedToAction = {
        SetInGameFriendType = {
            events.SetInGameFriendType,
            events.UpdateNumberFriends,
        },
        RemoveInGameFriend = {
            events.RemoveInGameFriend,
            events.UpdateNumberFriends,
        },
    }

    return signals
end

return module