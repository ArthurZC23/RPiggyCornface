local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local localPlayer = Players.LocalPlayer

local CharNpcAnimationsC = {}
CharNpcAnimationsC.__index = CharNpcAnimationsC
CharNpcAnimationsC.className = "CharNpcAnimations"
CharNpcAnimationsC.TAG_NAME = CharNpcAnimationsC.className

function CharNpcAnimationsC.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
        tracks = {},
        numAnimations = 0,
    }
    setmetatable(self, CharNpcAnimationsC)

    if not self:getFields() then return end
    self:preloadAnimations()

    return self
end

function CharNpcAnimationsC:preloadAnimations()
    -- self:_preloadEmotesAnimations()
end

function CharNpcAnimationsC:_preloadEmotesAnimations()
    local animationsData = Data.Animations[("CoreAnimationsMonster%s"):format(self.monsterId)].emotes
    for name, animation in pairs(animationsData) do
        self:LoadAnimation(animation)
    end
end

function CharNpcAnimationsC:LoadAnimation(animation)
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

function CharNpcAnimationsC:clearAnimations(animation)
    warn("Clear animations")
end

function CharNpcAnimationsC:playAnimation(animation)
    local track = self:LoadAnimation(animation)
    track:Play()
end

local S = Data.Strings.Strings

function CharNpcAnimationsC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return end

            do
                local bindersData = {
                    {"CharParts", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            self.monsterId = self.char:GetAttribute("monsterId")
            if not self.monsterId then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharNpcAnimationsC:Destroy()
    self._maid:Destroy()
end

return CharNpcAnimationsC