
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local CharacterPlayerC = {}
CharacterPlayerC.__index = CharacterPlayerC
CharacterPlayerC.className = "CharacterPlayer"
CharacterPlayerC.TAG_NAME = CharacterPlayerC.className

function CharacterPlayerC.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, CharacterPlayerC)

    return self
end

function CharacterPlayerC:updateChar()
    self._maid:Add(Players.CharacterAdded:Connect(function(char)
        self.char = char
    end))
    self.char = self.player.Character
end

function CharacterPlayerC:Destroy()
    self._maid:Destroy()
end

return CharacterPlayerC