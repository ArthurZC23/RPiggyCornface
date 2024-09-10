local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})

local SpinBlockS = {}
SpinBlockS.__index = SpinBlockS
SpinBlockS.className = "SpinBlock"
SpinBlockS.TAG_NAME = SpinBlockS.className

function SpinBlockS.new(inst)
    local self = {
        inst = inst,
        _maid = Maid.new(),
    }
    setmetatable(self, SpinBlockS)


    if not self:getFields() then return end
    self:spin()

    return self
end

function SpinBlockS:spin()
    self._maid:Add(BigBen.every(function() return self.inst:GetAttribute("RotationStep") or 1 end, "Heartbeat", "frame", true):Connect(function(_, timeStep)
        local theta = Vector3.zero
        local cf0 = self.inst:GetPivot()
        theta += self.inst:GetAttribute("AngularVelocity") * timeStep
        self.inst:PivotTo(cf0 * CFrame.Angles(theta.X, theta.Y, theta.Z))
    end))
end

function SpinBlockS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.inst.Parent
        end,
    })
    return ok
end

function SpinBlockS:Destroy()
    self._maid:Destroy()
end

return SpinBlockS