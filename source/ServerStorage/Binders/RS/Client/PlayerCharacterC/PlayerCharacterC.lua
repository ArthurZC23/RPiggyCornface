local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local BigTable = Mod:find({"BigTable", "BigTable"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local PlayerCharacterC = {}
PlayerCharacterC.__index = PlayerCharacterC
PlayerCharacterC.className = "PlayerCharacter"
PlayerCharacterC.TAG_NAME = PlayerCharacterC.className

function PlayerCharacterC.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerCharacterC)

    if not self:getFields(char) then return end
    self:addUidToChar(char)

    return self
end

function PlayerCharacterC:addUidToChar(char)
    self._maid:Add(BigTable.set("uid", self.charId, char))
end

function PlayerCharacterC:getFields(char)
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(char)
            if not self.player then return end

            self.charId = self.char:GetAttribute("uid")
            if not self.charId then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function PlayerCharacterC:Destroy()
    self._maid:Destroy()
end

return PlayerCharacterC