local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local InstanceUtils = Mod:find({"InstanceUtils", "Utils"})
local CFrameUtils = Mod:find({"Mosby", "CFrameUtils"})

local ParticleEmitter3D = {}
ParticleEmitter3D.__index = ParticleEmitter3D

function ParticleEmitter3D.new(props, kwargs)
    kwargs = kwargs or {}

    local self = {
        _maid = Maid.new(),
        particleEmitter = {},
        random = {
            Lifetime = Random.new(),
            Speed = Random.new(),
            thetaX = Random.new(),
            thetaY = Random.new(),
        }
    }
    setmetatable(self, ParticleEmitter3D)
    self:createPaticleEmitter(props)
    return self
end

function ParticleEmitter3D:validateProps(props)
    for prop in pairs(props) do
        assert(ParticleEmitter3D.props[prop], ("ParticleEmitter3D doesn't have property %s."):format(prop))
    end
end

function ParticleEmitter3D:createPaticleEmitter(props)
    self:validateProps(props)
    TableUtils.setTable(self.particleEmitter, props)
    TableUtils.setProto(self.particleEmitter, {
        Acceleration = Vector3.new(0, 0, 0),
        BasePart = GaiaShared.create("Part"),
        Color = function(part, lifetime) end,
        Rotation = function(part, lifetime) end,
        RotationSpeed = function(part, lifetime) end,
        Size = function(part, lifetime) end,
        Transparency = function(part, lifetime) end,
        EmissionDirection = Enum.NormalId.Top,
        Enabled = false,
        Lifetime = function() return self.random.Lifetime:NextNumber() end,
        Speed = function() return 0 end,
        Rate = 0,
        SpreadAngle = Vector2.new(0, 0),
        Shape = "Box",
        ShapeInOut = "Outward",
        ShapeStyle = "Volume",
        Drag = 0,
        LockedToPart = false,
        VelocityInheritance = 0,
        Material = Enum.Material.SmoothPlastic,
    })
    TableUtils.setInstance(self.particleEmitter.BasePart, {
        -- CanCollide = false,
        -- CanQuery = false,
        CastShadow = false,
        CanTouch = false,
    })
    self._maid:Add(self.particleEmitter.BasePart)
end

function ParticleEmitter3D:Emit(qty)
    assert(self.particleEmitter.parent, "ParticleEmitter3D requires parent before emission.")
    for i = 1, qty do
        local part = self.particleEmitter.BasePart:Clone()

        local lifetime = self.particleEmitter.Lifetime(part, self.random.Lifetime)
        self.particleEmitter.Size(part, lifetime)

        self:setSpawnPosition(part, self.particleEmitter.parent)
        local attach = GaiaShared.create("Attachment", {
            Parent = part,
        })

        GaiaShared.create("VectorForce", {
            ApplyAtCenterOfMass = true,
            Attachment0 = attach,
            Force = Vector3.new(0, part:GetMass() * workspace.Gravity, 0),
            RelativeTo = Enum.ActuatorRelativeTo.World,
            Name = "AntiGravity",
            Parent = part,
        })
        local acceleration
        if typeof(self.particleEmitter.Acceleration) == "function" then
            acceleration = self.particleEmitter.Acceleration()
        else
            acceleration = self.particleEmitter.Acceleration
        end
        GaiaShared.create("VectorForce", {
            ApplyAtCenterOfMass = true,
            Attachment0 = attach,
            Force = part:GetMass() * acceleration,
            RelativeTo = Enum.ActuatorRelativeTo.World,
            Name = "Acceleration",
            Parent = part,
        })

        local speed = self.particleEmitter.Speed(part)
        self.particleEmitter.Color(part, lifetime)
        self.particleEmitter.Transparency(part, lifetime)
        Debris:AddItem(part, lifetime)

        part.Name = tostring(i)
        part.Parent = workspace.Tmp.Vfx.Particles3D
        if RunService:IsServer() then
            part:SetNetworkOwner(nil)
        end
        do
            local dir = CFrameUtils.normalIdToCFrameVector(self.particleEmitter.parent.CFrame, self.particleEmitter.EmissionDirection)
            local x, y = CFrameUtils.getOrthogonalVectors(dir)
            local thetaX, thetaY
            local SpreadAngle
            if typeof(self.particleEmitter.SpreadAngle) == "function" then
                SpreadAngle = self.particleEmitter.SpreadAngle()
            else
                SpreadAngle = self.particleEmitter.SpreadAngle
            end
            do
                local v = SpreadAngle.X
                thetaX = -v + 2 * v * self.random.thetaX:NextNumber()
            end
            do
                local v = SpreadAngle.Y
                thetaY = -v + 2 * v * self.random.thetaY:NextNumber()
            end
            local dirx
            local dirxy
            if thetaX == 0 then
                dirx = dir
            else
                dirx = CFrameUtils.vectorRotation(dir, x, thetaX)
            end
            if thetaY == 0 then
                dirxy = dirx
            else
                dirxy = CFrameUtils.vectorRotation(dirx, y, thetaY)
            end
            part:ApplyImpulse(part:GetMass() * speed * dirxy)
        end
        do
            self.particleEmitter.Rotation(part, lifetime)
            self.particleEmitter.RotationSpeed(part, lifetime)
        end
    end
end

function ParticleEmitter3D:setSpawnPosition(part, parent)
    if parent:IsA("Attachment") then
        part.Position = parent.WorldPosition
    elseif parent:IsA("BasePart") then
        part.Position = InstanceUtils.getPointSamplerInstanceVolume(parent)()
    else
        error(("Invalid parent %s class %s"):format(parent:GetFullName(), parent.ClassName))
    end
end

function ParticleEmitter3D:setProps(props)
    self:validateProps(props)
    TableUtils.setTable(self.particleEmitter, props)
end

function ParticleEmitter3D:setBasePartProps(props)
    TableUtils.setInstance(self.particleEmitter.BasePart, props)
end

function ParticleEmitter3D:Destroy()
    self._maid:Destroy()
end

ParticleEmitter3D.props = {
    BasePart = true,
    Color = true,
    Rotation = true,
    RotationSpeed = true,
    Size = true,
    Transparency = true,
    EmissionDirection = true,
    Enabled = true,
    Lifetime = true,
    Speed = true,
    Rate = true,
    SpreadAngle = true,
    Shape = true,
    ShapeInOut = true,
    ShapeStyle = true,
    Acceleration = true,
    Drag = true,
    LockedToPart = true,
    VelocityInheritance = true,
    Material = true,
    parent = true,
}

return ParticleEmitter3D