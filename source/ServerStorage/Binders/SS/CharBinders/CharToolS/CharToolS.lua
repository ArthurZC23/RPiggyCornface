local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local CharTools = {}
CharTools.__index = CharTools
CharTools.className = "CharTools"
CharTools.TAG_NAME = CharTools.className

function CharTools.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharTools)
    if not self:getFields() then return end

    self:addStuidoTools()

    return self
end

function CharTools:addStuidoTools()
    if not RunService:IsStudio() then return end
    local tools = {

    }
    for _, toolProto in ipairs(tools) do
        local tool = ServerStorage.Assets.Tools[toolProto]:Clone()
        tool.Parent = self.player.Backpack
    end
end

function CharTools:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharTools:Destroy()
    self._maid:Destroy()
end

return CharTools