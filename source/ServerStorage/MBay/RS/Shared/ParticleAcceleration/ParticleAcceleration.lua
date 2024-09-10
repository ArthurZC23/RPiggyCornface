local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local ParticleAccelerationC = {}
ParticleAccelerationC.__index = ParticleAccelerationC
ParticleAccelerationC.className = "ParticleAcceleration"

function ParticleAccelerationC.new(particle, part)
    local self = {
        _maid = Maid.new(),
        particle = particle,
    }
    setmetatable(self, ParticleAccelerationC)

    if not self:getFields() then return end
    self:updateAcceleration(particle, part)

    return self
end

local BigBen = Mod:find({"Cronos", "BigBen"})
function ParticleAccelerationC:updateAcceleration(particle, part)
    local a = particle.Acceleration

    self._maid:Add2(
        BigBen.every(1, "Heartbeat", "frame", true):Connect(function()
            self.particle.Acceleration = part.CFrame:VectorToWorldSpace(a)
        end)
    )
end

function ParticleAccelerationC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function(kwargs)
            return true
        end,
        keepTrying=function()
            return self.particle.Parent
        end,
    })
    return ok
end

function ParticleAccelerationC:Destroy()
    self._maid:Destroy()
end

return ParticleAccelerationC