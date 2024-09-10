local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharSpeedGpC = {}
CharSpeedGpC.__index = CharSpeedGpC
CharSpeedGpC.className = "CharSpeedGp"
CharSpeedGpC.TAG_NAME = CharSpeedGpC.className

function CharSpeedGpC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end
    if char:HasTag("PlayerMonster") then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharSpeedGpC)

    if not self:getFields() then return end
    self:handleSpeed()

    return self
end

function CharSpeedGpC:handleSpeed()
    local prop = self.charProps.props[self.charParts.humanoid]
    local cause = "GpBoost"
    prop:set("WalkSpeed", cause, 22)
end

function CharSpeedGpC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharParts", self.char},
                {"CharProps", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=1
    })
    return ok
end

function CharSpeedGpC:Destroy()
    self._maid:Destroy()
end

return CharSpeedGpC