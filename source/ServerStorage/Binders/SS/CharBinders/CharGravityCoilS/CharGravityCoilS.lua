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

local CharGravityCoilS = {}
CharGravityCoilS.__index = CharGravityCoilS
CharGravityCoilS.className = "CharGravityCoil"
CharGravityCoilS.TAG_NAME = CharGravityCoilS.className

function CharGravityCoilS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharGravityCoilS)

    if not self:getFields() then return end
    self:addTool()

    return nil
end

function CharGravityCoilS:addTool()
    local tool = ServerStorage.Assets.Tools.GravityCoil:Clone()
    tool.Parent = self.backpack
end

function CharGravityCoilS:getFields()
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

function CharGravityCoilS:Destroy()
    self._maid:Destroy()
end

return CharGravityCoilS