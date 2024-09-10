local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local CharDamageS = {}
CharDamageS.__index = CharDamageS
CharDamageS.className = "CharDamage"
CharDamageS.TAG_NAME = CharDamageS.className

function CharDamageS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharDamageS)

    if not self:getFields() then return end
    self:createSignals()
    self:handleDamage()

    return self
end

function CharDamageS:isInvencible()
    local boostState = self.playerState:get(S.Stores, "Boosts")
    local hasNoDamageBoost = boostState.st[Data.Boosts.Boosts.nameData[S.NoDamageBoost].id] ~= nil
    if hasNoDamageBoost then return true end
    return false
end

function CharDamageS:handleDamage()
    self._maid:Add(self.DamageSE:Connect(function(damage, kwargs)
        kwargs  = kwargs or {}
        if self:isInvencible() then return end
        local health = self.charParts.humanoid.Health - damage
        if health <= 0 and  kwargs.deathCause then
            self.charHades.KillSignalSE:Fire(kwargs.deathCause)
        else
            self.charParts.humanoid.Health = self.charParts.humanoid.Health - damage
        end
    end))
    self._maid:Add(self.DamageKillSE:Connect(function(kwargs)
        kwargs  = kwargs or {}
        if self:isInvencible() then return end

        local hideState = self.charState:get(S.Session, "Hide")
        if hideState.on then return end

        if kwargs.deathCause then
            self.charHades.KillSignalSE:Fire(kwargs.deathCause, kwargs)
        else
            self.charParts.humanoid.Health = 0
        end
    end))
end

function CharDamageS:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.char, {
        events = {"Damage", "DamageKill"},
    }))
end

local Players = game:GetService("Players")
function CharDamageS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            if not self.player then return end
            local bindersData = {
                {"PlayerState", self.player},
                {"CharParts", self.char},
                {"CharState", self.char},
                {"CharHades", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharDamageS:Destroy()
    self._maid:Destroy()
end

return CharDamageS