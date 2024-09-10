local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharTeamHumanS = {}
CharTeamHumanS.__index = CharTeamHumanS
CharTeamHumanS.className = "CharTeamHuman"
CharTeamHumanS.TAG_NAME = CharTeamHumanS.className

function CharTeamHumanS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharTeamHumanS)

    if not self:getFields() then return end
    self:loadAnimations()
    self:loadSounds()
    self:loadParticles()
    self:createRemotes()

    return self
end

function CharTeamHumanS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"HideChar"},
        functions = {},
    }))
end

function CharTeamHumanS:loadAnimations()
    self.tracks = {}
    self.tracks.killAnimation = self.charParts.animator:LoadAnimation(Data.Animations.Animations.Kills.OnFloor_1.Human)
end

function CharTeamHumanS:loadSounds()
    self.Sounds = BinderUtils.loadSounds({
        Scream = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.Scream,
            parent = self.charParts.hrp,
        },
    })
end

function CharTeamHumanS:loadParticles()
    local particlesData = {
        KillEffect_1 = {
            proto = ReplicatedStorage.Assets.Particles.KillEffect_1,
            parent = self.charParts.hrp,
        },
    }
    self.Particles = {}
    for name, data in pairs(particlesData) do
        local Particle = data.proto:Clone()
        Particle.Parent = data.parent
        self.Particles[name] = Particle
    end
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharTeamHumanS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharProps", self.char},
                {"CharParts", self.char},
                {"CharState", self.char},
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharTeamHumanS:Destroy()
    self._maid:Destroy()
end

return CharTeamHumanS