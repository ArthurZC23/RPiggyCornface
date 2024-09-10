local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Bach = Mod:find({"Bach", "Bach"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local Sfxs = {}
Sfxs.__index = Sfxs
Sfxs.className = "Sfxs"
Sfxs.TAG_NAME = Sfxs.className

function Sfxs.new(playerSounds)
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Sfxs)

    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=playerSounds.player})
    if not playerState then return end

    self:sfxForPurchase(playerState)

    return self
end

function Sfxs:sfxForPurchase(playerState)
    local function playSfx()
        Bach:play("ChaChing", Bach.SoundTypes.SfxGui)
    end

    playSfx = Debounce.standard(playSfx)
    playerState:getEvent(S.Stores, "GamePasses", "addGamePass"):Connect(playSfx)
    playerState:getEvent(S.Stores, "Money_1", "Increment"):Connect(function(_, action)
        if action.ux then
            playSfx()
        end
    end)
    playerState:getEvent(S.Stores, "Money_1", "Decrement"):Connect(function(_, action)
        if action.ux then
            playSfx()
        end
    end)
    playerState:getEvent(S.Stores, "MoneyMonster", "Increment"):Connect(function(_, action)
        if action.ux then
            playSfx()
        end
    end)
    playerState:getEvent(S.Stores, "MonsterSkins", "add"):Connect(function(_, action)
        if action.ux then
            playSfx()
        end
    end)
    playerState:getEvent(S.Stores, "SpinWheels", "addSpin"):Connect(function(_, action)
        if action.ux then
            playSfx()
        end
    end)
    playerState:getEvent(S.Session, "Lives", "add"):Connect(function(_, action)
        if action.ux then
            playSfx()
        end
    end)
    playerState:getEvent(S.Session, "MapTokens", "add"):Connect(function(_, action)
        if action.ux then
            Bach:play("TokenPickup", Bach.SoundTypes.SfxGui)
        end
    end)
end

function Sfxs:Destroy()
    self._maid:Destroy()
end

return Sfxs