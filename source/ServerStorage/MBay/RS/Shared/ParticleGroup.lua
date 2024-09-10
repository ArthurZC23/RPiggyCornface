local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local TableUtils = Mod:find({"Table", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local InstanceUtils = Mod:find({"InstanceUtils", "Utils"})
local Maid = Mod:find({"Maid"})

local ParticleGroup = {}
ParticleGroup.__index = ParticleGroup

function ParticleGroup.new(particles, kwargs)
    kwargs = kwargs or {}
    local self = {
        particles = particles or {},
        emitValues = kwargs.emitValues or {},
        timers = kwargs.timers or {},
        rate = kwargs.rate or 0,
        enabled = kwargs.enabled or false,
        _maid = Maid.new(),
    }
    setmetatable(self, ParticleGroup)
    assert(self:allNamesAreDifferent(particles), "Particles need to have different names.")
    self._maid:Add(function()
        for _, particle in ipairs(self.particles) do
            particle:Destroy()
        end
    end)
    if kwargs.parent then
        self:setParent(kwargs.parent)
    end
    if kwargs.config then
        self:config(kwargs.config)
    end
    return self
end

function ParticleGroup:allNamesAreDifferent(particles)
    return #self.particles == #Functional.unique(particles)
end

function ParticleGroup:EmitAllEqual(val)
    for _, particle  in ipairs(self.particles) do
        particle:Emit(val)
    end
end

function ParticleGroup:Emit(emitValues)
    emitValues = emitValues or {}
    local parentPosition = self.parentPositionSampler()
    self.parent.WorldPosition = parentPosition
    for _, particle  in ipairs(self.particles) do
        local val = emitValues[particle.Name] or self.emitValues[particle.Name] or 0
        if self.timers[particle.Name] then
            task.delay(self.timers[particle.Name], function()
                particle:Emit(val)
            end)
        else
            particle:Emit(val)
        end
    end
end

function ParticleGroup:ClearAll()
    for _, particle  in ipairs(self.particles) do
        particle:Clear()
    end
end

function ParticleGroup:setParent(parent)
    local _parent
    if parent:IsA("BasePart") then
        _parent = self._maid:Add(GaiaShared.create("Attachment", {
            Name = "_ParticleGroupAttach",
            Parent = parent,
        }))
        self.shapeStyle = self.shapeStyle or "Volume"
        if self.shapeStyle then
            if self.shapeStyle == "Volume" then
                self.parentPositionSampler = InstanceUtils.getPointSamplerInstanceVolume(parent)
            elseif self.shapeStyle == "Surface" then
                self.parentPositionSampler = InstanceUtils.getPointSamplerInstanceSurface(parent)
            end
        else
            return InstanceUtils.getPointSamplerInstanceVolume(parent)
        end
    else
        _parent = parent
        self.parentPositionSampler = function() return parent.WorldPosition end
    end
    for _, particle  in ipairs(self.particles) do
        particle.Parent = _parent
    end
    self.parent = _parent
end

function ParticleGroup:setTimers(timers)
    self.timers = timers
end

function ParticleGroup:setEmitValues(emitValues)
    self.emitValues = emitValues
end

function ParticleGroup:setRate(rate)
    assert(rate >= 0, "Rate must be positive.")
    self.rate = rate
    self:updateStream()
end

function ParticleGroup:Enable()
    self.enabled = true
    self:updateStream()
end

function ParticleGroup:Disable()
    self.enabled = false
    self.updateStream()
end

function ParticleGroup:updateStream()
    local maidId = "ParticleGroupEnable"
    if not (self.rate > 0 and self.enabled) then
        self._maid:Remove(maidId)
        return
    end
    self._maid:Add(
        BigBen.every(
            function()
                if self.rate > 0 then
                    return 1 / self.rate
                end
                return 0.1
            end,
            "Heartbeat",
            "time_",
            true
        ):Connect(function()
            if not (self.rate > 0 and self.enabled) then return end
            self:Emit(self.emitValues)
        end),
        "Disconnect",
        maidId
    )
end

function ParticleGroup:config(config)
    for _, particle  in ipairs(self.particles) do
        TableUtils.setInstance(particle, config[particle.Name])
    end
end

function ParticleGroup:Destroy()
    self._maid:Destroy()
end

return ParticleGroup