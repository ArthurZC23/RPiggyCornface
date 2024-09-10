local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})

local SpinMotor6dClientC = {}
SpinMotor6dClientC.__index = SpinMotor6dClientC
SpinMotor6dClientC.className = "SpinMotor6dClient"
SpinMotor6dClientC.TAG_NAME = SpinMotor6dClientC.className

function SpinMotor6dClientC.new(motor)
    local self = {
        motor = motor,
        _maid = Maid.new(),
    }
    setmetatable(self, SpinMotor6dClientC)

    if not self:getFields() then return end
    self:spin()

    return self
end

function SpinMotor6dClientC:spin()
    self._maid:Add(BigBen.every(function() return self.motor:GetAttribute("RotationStep") or 1 end, "Heartbeat", "frame", true):Connect(function(_, timeStep)
        local theta = self.motor:GetAttribute("AngularVelocity") * timeStep
        self.motor.C0 = self.motor.C0 * CFrame.Angles(theta.X, theta.Y, theta.Z)
    end))
end

function SpinMotor6dClientC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.motor.Parent
        end,
    })
    return ok
end

function SpinMotor6dClientC:Destroy()
    self._maid:Destroy()
end

return SpinMotor6dClientC