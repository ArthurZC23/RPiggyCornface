local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})

local function setAttributes()

end
setAttributes()

local MonsterS = {}
MonsterS.__index = MonsterS
MonsterS.className = "Monster"
MonsterS.TAG_NAME = MonsterS.className

function MonsterS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, MonsterS)

    if not self:getFields() then return end

    self:setSpeed()
    self:setLight()
    self:loadAnimations()
    self:handleSounds()
    self:setParticles()
    self:setTags()
    self:handleKillOnTouch()

    return self
end

function MonsterS:setLight()
    local Light = ReplicatedStorage.Assets.Lights.MonsterRedLight:Clone()
    Light.Parent = self.charParts.hrp
end

function MonsterS:loadAnimations()
    self.tracks = {}
    self.tracks.killAnimation = self.charParts.animator:LoadAnimation(Data.Animations.Animations.Kills.OnFloor_1.Monster)
end

function MonsterS:setTags()
    local skinId = self.char:GetAttribute("skinId")
    local data = Data.MonsterSkins.MonsterSkins.idData[skinId]
    if data.tags then
        for _, tag in ipairs(data.tags) do
            self.char:AddTag(tag)
        end
    end
end

local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})
function MonsterS:handleKillOnTouch()
    self._maid:Add(self.charParts.Toucher.Touched:Connect(InstanceDebounce.playerHrpCooldownPerPlayer(
        function(_, targetChar)
            if not Data.Studio.Studio.monsterCanKill then return end
            if self.char:GetAttribute("canKill") == false then return end
            if targetChar:HasTag("Monster") then return end

            local charState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharState", inst = targetChar})
            if not charState then return end
            local hideState = charState:get(S.Session, "Hide")
            if hideState.on then return end

            local charTeamHuman = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharTeamHuman", inst = targetChar})
            if not charTeamHuman then return end

            local charParts = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharParts", inst = targetChar})
            if not charParts then return end
            if charParts.humanoid.Health <= 0 then return end

            local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
            if not targetPlayer then return end

            local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = targetPlayer})
            if not playerState then return end

            local boostState = playerState:get(S.Stores, "Boosts")
            local BoostData = Data.Boosts.Boosts.nameData
            if boostState.st[BoostData[S.GhostBoost].id]  ~= nil then return true end

            local DamageKillSE = SharedSherlock:find({"Bindable", "sync"}, {root = targetChar, signal = "DamageKill"})
            if not DamageKillSE then return end
            DamageKillSE:Fire({
                deathCause="MonsterKill",
                killerData = {
                    inst = self.char,
                    binders = {
                        charParts = self.charParts,
                        charProps = self.charProps,
                        monster = self,
                    },
                },
                targetData = {
                    binders = {
                        charTeamHuman = charTeamHuman,
                    },
                },
            })

            if self.playerState then
                local killValue = 1
                do
                    local action = {
                        name = "increment",
                        scoreType = S.Kills,
                        timeType = "allTime",
                        value = killValue,
                    }
                    self.playerState:set(S.Stores, "Scores", action)
                end
                do
                    local action = {
                        name = "Increment",
                        value = killValue * Data.MonsterSkins.MonsterSkins.playerMonster.money_1KillRatio
                    }
                    self.playerState:set(S.Stores, "Money_1", action)
                end
            end
        end,
        1
    )))
end

function MonsterS:setParticles()
    for _, desc in ipairs(self.char:GetDescendants()) do
        if desc:IsA("ParticleEmitter") then
            desc.Enabled = true
        end
    end
end

function MonsterS:setSpeed()
    self.charParts.humanoid.WalkSpeed = 16 - 0.5
end

function MonsterS:loadSounds()
    self.Sounds = BinderUtils.loadSounds({
        ScaryChase = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.ScaryChase,
            parent = self.charParts.hrp,
        },
        ChainsawOn = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.ChainsawOn,
            parent = self.charParts.hrp,
        },
        Laugh = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.Laugh,
            parent = self.charParts.hrp,
        },
        ChainsawShort = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.ChainsawShort,
            parent = self.charParts.hrp,
        },
        ChainsawKill = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.ChainsawKill,
            parent = self.charParts.hrp,
        },
    })
end

function MonsterS:handleChaseSoundtrack()
    -- self.Sounds.ScaryChase:Play()
    self.Sounds.ChainsawOn:Play()
end

local BigBen = Mod:find({"Cronos", "BigBen"})
function MonsterS:handleLaughSfx()
    local randomTime = Random.new()
    self._maid:Add(BigBen.every(function() return randomTime:NextInteger(5, 10) + self.Sounds.Laugh.TimeLength + self.Sounds.ChainsawShort.TimeLength end, "Heartbeat", "time_", false):Connect(function()
    -- self._maid:Add(BigBen.every(function() return 5 + self.Sounds.Laugh.TimeLength + self.Sounds.ChainsawShort.TimeLength end, "Heartbeat", "time_", false):Connect(function()
        self.Sounds.Laugh:Play()
        self._maid:Add2(Promise.fromEvent(self.Sounds.Laugh.Ended)
        :andThen(function()
            self.Sounds.ChainsawShort:Play()
        end),
        "SoundEnded_Laugh")
    end))
end

function MonsterS:handleShortChainsawSfx()

end

function MonsterS:handleSounds()
    if RunService:IsStudio() and Data.Studio.Studio.muteMonsterSound then return end
    self:loadSounds()
    self:handleChaseSoundtrack()
    self:handleLaughSfx()
    self:handleShortChainsawSfx()
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Players = game:GetService("Players")
function MonsterS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            do
                local bindersData = {
                    {"CharParts", self.char},
                    {"CharProps", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            if self.char:HasTag("PlayerMonster") then
                self.player = Players:GetPlayerFromCharacter(self.char)
                if not self.player then return end
                do
                    local bindersData = {
                        {"PlayerState", self.player},
                    }
                    if not BinderUtils.addBindersToTable(self, bindersData) then return end
                end
            end

            self.monsterId = self.char:GetAttribute("monsterId")
            if not self.monsterId then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function MonsterS:Destroy()
    self._maid:Destroy()
end

return MonsterS