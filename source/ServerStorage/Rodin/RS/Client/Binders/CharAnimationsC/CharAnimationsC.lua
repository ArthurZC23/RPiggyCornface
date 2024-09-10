local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local Animations = Data.Animations.Animations
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local localPlayer = Players.LocalPlayer

local CharAnimationsC = {}
CharAnimationsC.__index = CharAnimationsC
CharAnimationsC.className = "CharAnimations"
CharAnimationsC.TAG_NAME = CharAnimationsC.className

function CharAnimationsC.new(char)
    if not CharUtils.isLocalChar(char) then return end

    local self = {
        _maid = Maid.new(),
        char = char,
        tracks = {},
        numAnimations = 0,
    }
    setmetatable(self, CharAnimationsC)

    if not self:getFields() then return end
    self:preloadAnimations()
    self:handleIdleAnimations()
    self:handleActionAnimations()

    return self
end

function CharAnimationsC:preloadAnimations()
    self:_preloadEmotesAnimations()
end

function CharAnimationsC:_preloadEmotesAnimations()
    local animationsData = Data.Animations.Animations[self.rigType].Emotes
    for name, animation in pairs(animationsData) do
        self:LoadAnimation(animation)
    end
end

function CharAnimationsC:LoadAnimation(animation)
    local track = self.tracks[animation.AnimationId]
    if not track then
        self.tracks[animation.AnimationId] = self.charParts.animator:LoadAnimation(animation)
        self.numAnimations += 1
        if self.numAnimations > 230 then
            self:clearAnimations()
        end
    end
    return self.tracks[animation.AnimationId]
end

function CharAnimationsC:clearAnimations(animation)
    warn("Clear animations")
end

function CharAnimationsC:playAnimation(animation)
    local track = self:LoadAnimation(animation)
    track:Play()
end

local S = Data.Strings.Strings
function CharAnimationsC:handleActionAnimations()
    local function stopAction1(state, action)
        self._maid:Remove("TrackAction1Stop")
        local track = self.tracks[action.trackAction1.AnimationId]
        track:Stop()
    end

    local function playAction1(state)
        -- local charCoreAnimations = SharedSherlock:find({"Binders", "getInstObj"}, {inst=self.char, tag="CharCoreAnimations"})
        -- if not charCoreAnimations then return end
        -- charCoreAnimations:stopAllAnimations()

        local track = self.tracks[state.trackAction1.AnimationId]
        self._maid:Add2(track.Stopped:Connect(function()
            local action = {
                name = "stopAction1Animation",
            }
            self.charState:set(S.LocalSession, "Animation", action)
        end), "TrackAction1Stop")
        track:Play()
    end
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Animation", "stopAction1Animation"):Connect(stopAction1))
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Animation", "playAction1Animation"):Connect(playAction1))


    local function stopAction2(state, action)
        self._maid:Remove("TrackAction2Stop")
        local track = self.tracks[action.trackAction2.AnimationId]
        track:Stop()
    end

    local function playAction2(state)
        -- local charCoreAnimations = SharedSherlock:find({"Binders", "getInstObj"}, {inst=self.char, tag="CharCoreAnimations"})
        -- if not charCoreAnimations then return end
        -- charCoreAnimations:stopAllAnimations()

        local track = self.tracks[state.trackAction2.AnimationId]
        self._maid:Add2(track.Stopped:Connect(function()
            local action = {
                name = "stopAction2Animation",
            }
            self.charState:set(S.LocalSession, "Animation", action)
        end), "TrackAction2Stop")
        track:Play()
    end
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Animation", "stopAction2Animation"):Connect(stopAction2))
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Animation", "playAction2Animation"):Connect(playAction2))
end

function CharAnimationsC:handleIdleAnimations()
    local function stopIdle(state, action)
        self._maid:Remove("TrackIdleStop")
        local track = self.tracks[action.trackIdle.AnimationId]
        if track then track:Stop() end
    end

    local function playIdle(state)
        local track = self.tracks[state.trackIdle.AnimationId]
        self._maid:Add2(track.Stopped:Connect(function()
            local action = {
                name = "stopIdleAnimation",
            }
            self.charState:set(S.LocalSession, "Animation", action)
        end), "TrackIdleStop")
        track:Play()
    end
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Animation", "stopIdleAnimation"):Connect(stopIdle))
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Animation", "playIdleAnimation"):Connect(playIdle))
end

function CharAnimationsC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return end

            do
                local bindersData = {
                    {"CharState", self.char},
                    {"CharParts", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharAnimationsC:Destroy()
    self._maid:Destroy()
end

return CharAnimationsC