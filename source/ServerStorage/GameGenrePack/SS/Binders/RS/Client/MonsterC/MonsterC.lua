local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local MonsterC = {}
MonsterC.__index = MonsterC
MonsterC.className = "Monster"
MonsterC.TAG_NAME = MonsterC.className

local function setAttributes()

end
setAttributes()

function MonsterC.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, MonsterC)

    if not self:getFields() then return end

    return self
end

function MonsterC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharParts", self.char},
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

function MonsterC:Destroy()
    self._maid:Destroy()
end

return MonsterC