local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local RootF = script:FindFirstAncestor("PlayerSoundsC")
local Sfxs = require(ComposedKey.getAsync(RootF, {"Components", "Sfxs"}))
local Soundtrack = require(ComposedKey.getAsync(RootF, {"Components", "Soundtrack"}))

local localPlayer = Players.LocalPlayer

local PlayerSoundsC = {}
PlayerSoundsC.__index = PlayerSoundsC
PlayerSoundsC.className = "PlayerSounds"
PlayerSoundsC.TAG_NAME = PlayerSoundsC.className

function PlayerSoundsC.new(player)
    if localPlayer ~= player then return end
    local self = {
        _maid = Maid.new(),
        player=player,
    }
    setmetatable(self, PlayerSoundsC)

    if not self:addComponents() then return end

    return self
end

function PlayerSoundsC:addComponents()
    self.soundtracks = Soundtrack.new(self)
    if not self.soundtracks then return end
    self._maid:Add(self.soundtracks)

    self.sfxs = Sfxs.new(self)
    if not self.sfxs then return end
    self._maid:Add(self.sfxs)
end

function PlayerSoundsC:Destroy()
    self._maid:Destroy()
end

return PlayerSoundsC