local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local CharAnimationMarkersS = {}
CharAnimationMarkersS.__index = CharAnimationMarkersS
CharAnimationMarkersS.className = "CharAnimationMarkers"
CharAnimationMarkersS.TAG_NAME = CharAnimationMarkersS.className

function CharAnimationMarkersS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
        callbacks = {},
    }
    setmetatable(self, CharAnimationMarkersS)

    if not self:getFields() then return end
    self:handleAnimationPlayed()

    return self
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharAnimationMarkersS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
end

function CharAnimationMarkersS:handleAnimationPlayed()
    self._maid:Add(self.charParts.animator.AnimationPlayed:Connect(function(track)
        local callbacks = self.callbacks[track.Animation.AnimationId] or {}
        for marker, markerCbs in pairs(callbacks) do
            local maidId = ("%s_%s"):format(track.Animation.AnimationId, marker)
            if marker == "Stopped" then
                self._maid:Add2(
                    track.Stopped:Connect(function()
                        self._maid:Remove(maidId)
                        for cbId, cb in pairs(markerCbs) do
                            task.spawn(cb, track, cbId)
                        end
                    end),
                    maidId
                )
            elseif marker == "Start" then
                for cbId, cb in pairs(markerCbs) do
                    task.spawn(cb, track, cbId)
                end
            else
                self._maid:Add2(
                    track:GetMarkerReachedSignal(marker):Connect(function()
                        self._maid:Remove(maidId)
                        for cbId, cb in pairs(markerCbs) do
                            task.spawn(cb, track, cbId)
                        end
                    end),
                    maidId
                )
            end
        end
    end))
end

function CharAnimationMarkersS:addCallback(AnimationId, marker, cbId, callback)
    assert(typeof(callback) == "function", "Callback must be a function.")
    self.callbacks[AnimationId] = self.callbacks[AnimationId] or {}
    self.callbacks[AnimationId][marker] = self.callbacks[AnimationId][marker] or {}
    assert(self.callbacks[AnimationId][marker][cbId] == nil, ("Animation %s marker %s already has id %s."):format(AnimationId, marker, cbId))
    self.callbacks[AnimationId][marker][cbId] = callback
    return function ()
        self:removeCallback(AnimationId, marker, cbId)
    end
end

function CharAnimationMarkersS:addCallbackOneCall(AnimationId, marker, cbId, callback)
    assert(typeof(callback) == "function", "Callback must be a function.")
    self.callbacks[AnimationId] = self.callbacks[AnimationId] or {}
    self.callbacks[AnimationId][marker] = self.callbacks[AnimationId][marker] or {}
    assert(self.callbacks[AnimationId][marker][cbId] == nil, ("Animation %s marker %s already has id %s."):format(AnimationId, marker, cbId))
    self.callbacks[AnimationId][marker][cbId] = function(...)
        callback(...)
        self:removeCallback(AnimationId, marker, cbId)
    end
    return function ()
        self:removeCallback(AnimationId, marker, cbId)
    end
end

function CharAnimationMarkersS:removeCallback(AnimationId, marker, cbId)
    -- local maidId = ("%s_%s"):format(AnimationId, marker)
    -- self._maid:Remove(maidId)
    self.callbacks[AnimationId][marker][cbId] = nil
end

function CharAnimationMarkersS:Destroy()
    self._maid:Destroy()
end

return CharAnimationMarkersS