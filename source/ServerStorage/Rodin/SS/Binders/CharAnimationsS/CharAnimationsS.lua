local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local CharAnimationsS = {}
CharAnimationsS.__index = CharAnimationsS
CharAnimationsS.className = "CharAnimations"
CharAnimationsS.TAG_NAME = CharAnimationsS.className

function CharAnimationsS.new(char)

    local self = {
        _maid = Maid.new(),
        char = char,
        tracks = {},
        numAnimations = 0,
    }
    setmetatable(self, CharAnimationsS)

    if not self:getFields() then return end
    self:createRemotes()

    return self
end

function CharAnimationsS:LoadAnimation(animation)
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

function CharAnimationsS:clearAnimations(animation)
    warn("Clear animations")
end

function CharAnimationsS:playAnimation(animation)
    local track = self:LoadAnimation(animation)
    track:Play()
end

function CharAnimationsS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            -- self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            -- if not self.player then return end

            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharAnimationsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"PlayAnimationTrack"},
        functions = {},
    }))
end

function CharAnimationsS:Play(track)
    self.PlayAnimationTrackRE:FireClient(self.player, track.Animation.AnimationId)
end

function CharAnimationsS:Destroy()
    self._maid:Destroy()
end

return CharAnimationsS