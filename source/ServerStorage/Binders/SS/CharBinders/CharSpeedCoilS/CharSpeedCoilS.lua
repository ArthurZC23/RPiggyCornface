local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})

local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharSpeedCoilS = {}
CharSpeedCoilS.__index = CharSpeedCoilS
CharSpeedCoilS.className = "CharSpeedCoil"
CharSpeedCoilS.TAG_NAME = CharSpeedCoilS.className

function CharSpeedCoilS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharSpeedCoilS)

    if not self:getFields() then return end
    self:addTool()

    return nil
end

function CharSpeedCoilS:addTool()
    local tool = ServerStorage.Assets.Tools.SpeedCoil:Clone()
    tool.Parent = self.backpack
end

function CharSpeedCoilS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local player = Players:GetPlayerFromCharacter(self.char)
            if not player then return end
            self.backpack = player.Backpack
            if not self.backpack then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
end

function CharSpeedCoilS:Destroy()
    self._maid:Destroy()
end

return CharSpeedCoilS