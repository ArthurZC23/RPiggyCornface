local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})

local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local AnimationsData = Data.Animations.Animations

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local CharAnimations = {}
CharAnimations.__index = CharAnimations
CharAnimations.className = "CharAnimationsBak"
CharAnimations.TAG_NAME = CharAnimations.className

function CharAnimations.new(char)
    if localPlayer.Name ~= char.Name then return end

    local self = {
        _maid = Maid.new(),
        char=char,
        animTracks = {
            Core = {},
            Idle = {},
            Movement = {},
            Action1 = {},
            Action2 = {},
            Action3 = {},
            Action4 = {},
        }
    }
    setmetatable(self, CharAnimations)

    if not self:getFields() then return end

    return self
end

function CharAnimations:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharAnimations:playAnimation(animType, animation, props)
    self._maid:Add(
        function()
            if self.animTracks[animType] then
                self.animTracks[animType]:Stop()
            end
        end,
        nil,
        animType
    )
    props = props or {}
    if not self.animTracks[animType] then
        self.animTracks[animType] = self.animator:LoadAnimation(animation)
    end
    TableUtils.setInstance(self.animTracks[animType], props)
    self.animTracks[animType]:Play()
end

function CharAnimations:stopAnimation(animType)
    self._maid:Remove(animType)
end

function CharAnimations:handleActionAnimations()

    self._maid:Add(playerState:getEvent(S.Session, "Animations", "playActionAnimation"):Connect(function(state, action)
        local animation = ComposedKey.get(AnimationsData, state.actionAnimationPath)
        self:playAnimation("actionAnimation", animation)
    end))

    self._maid:Add(playerState:getEvent(S.Session, "Animations", "stopActionAnimation"):Connect(function(state, action)
        self:stopAnimation("actionAnimation")
    end))

    local state = playerState:get(S.Session, "Animations")
    if state.actionAnimationPath then
        local animation = ComposedKey.get(AnimationsData, state.actionAnimationPath)
        self:playAnimation("actionAnimation", animation)
    end
end

function CharAnimations:Destroy()
    self._maid:Destroy()
end

return CharAnimations