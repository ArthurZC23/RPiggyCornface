
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local CharacterPlayerS = {}
CharacterPlayerS.__index = CharacterPlayerS
CharacterPlayerS.className = "CharacterPlayer"
CharacterPlayerS.TAG_NAME = CharacterPlayerS.className

function CharacterPlayerS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, CharacterPlayerS)

    return self
end

function CharacterPlayerS:updateChar()
    self._maid:Add(Players.CharacterAdded:Connect(function(char)
        self.char = char
    end))
    self.char = self.player.Character
end

function CharacterPlayerS:Destroy()
    self._maid:Destroy()
end

return CharacterPlayerS