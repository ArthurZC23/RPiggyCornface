local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local CharAnimationsEventsS = {}
CharAnimationsEventsS.__index = CharAnimationsEventsS
CharAnimationsEventsS.className = "CharAnimationsEvents"
CharAnimationsEventsS.TAG_NAME = CharAnimationsEventsS.className

function CharAnimationsEventsS.new(char)
    local player = PlayerUtils:GetPlayerFromCharacter(char)
    if not player then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        player = player,
    }
    setmetatable(self, CharAnimationsEventsS)

    do
        local ok = self:getFields(player)
        if not ok then return end
    end
    self:createRemotes()

    return self
end

function CharAnimationsEventsS:getFields(player)
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharAnimationsEventsS:createRemotes()
    -- other system can listen to this events
    local eventsNames = {"KeyframeReached", "Stopped", "DidLoop", "GetMarkerReachedSignal"}
    GaiaServer.createRemotes(self.charEvents, {
        events = eventsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        CharAnimationsEventsS[("%sRE"):format(eventName)] = self.charEvents.Remotes.Events[eventName]
    end
end

function CharAnimationsEventsS:Destroy()
    self._maid:Destroy()
end

return CharAnimationsEventsS