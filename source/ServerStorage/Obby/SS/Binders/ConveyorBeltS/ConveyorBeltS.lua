local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local ConveyorBeltS = {}
ConveyorBeltS.__index = ConveyorBeltS
ConveyorBeltS.className = "ConveyorBelt"
ConveyorBeltS.TAG_NAME = ConveyorBeltS.className

function ConveyorBeltS.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, ConveyorBeltS)

    if not self:getFields() then return end
    self:handleConveyorBeltSpeed()

    return self
end

function ConveyorBeltS:handleConveyorBeltSpeed()
    local velocity = self.part:GetAttribute("ConveyorBeltVelocity")
    local cf = self.part.CFrame
    local realVelocity =
        cf.RightVector * velocity.X
        + cf.UpVector * velocity.Y
        + cf.LookVector * velocity.Z
    self.part.Velocity = realVelocity
end

function ConveyorBeltS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.part.Parent
        end,
    })
    return ok
end

function ConveyorBeltS:Destroy()
    self._maid:Destroy()
end

return ConveyorBeltS