local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})

local Rocks = {}
Rocks.__index = Rocks
Rocks.className = "Rocks"
Rocks.TAG_NAME = Rocks.className

local rockProto = GaiaShared.create("Part", {
    Anchored = true,
    CastShadow = false,
    CanCollide = false,
    CanTouch = false,
    Position = Vector3.new(1e10, 1e10, 1e10),
    Size = Vector3.new(1, 1, 1),
})

function Rocks.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Rocks)

    return self
end

function Rocks:createSimpleCircle(position, distanceFromCenter, size, raycastParams, kwargs)
    kwargs = kwargs or {}
    local random = Random.new()
    local maxRocks = kwargs.maxRocks or 20
    local offset = kwargs.offset or Vector3.zero

    local theta = 0
    local thetaStep = 360 / maxRocks

    local rocksDuration = kwargs.rocksDuration or 2
    local rockGroup = Instance.new("Model")

    for i = 1, maxRocks do
        local cf = CFrame.new(position)
        local newCF = cf * CFrame.fromEulerAnglesXYZ(0, math.rad(theta), 0) * CFrame.new(0.5 * distanceFromCenter + 0.1 * distanceFromCenter, 10, 0)
        local ray = workspace:Raycast(newCF.Position, Vector3.new(0, -20, 0), raycastParams)
        theta += thetaStep
        if ray then
            local soil = rockProto:Clone()
            local rock = rockProto:Clone()

            soil.Name = ("Soil_%s"):format(i)
            rock.Name = ("Rock_%s"):format(i)

            soil.CFrame =
                CFrame.new(ray.Position - Vector3.new(0, size.Y * 0.4, 0), position)
                * CFrame.fromEulerAnglesXYZ(random:NextNumber(-1, -0.3), random:NextNumber(-0.15, 0.15), random:NextNumber(-.15, .15))
                + offset
            soil.Size = Vector3.new(size.X * 1.3, size.Y * 0.7, size.Z * 1.3) * random:NextNumber(1, 1.5)

            rock.Size = Vector3.new(soil.Size.X * 1.01, soil.Size.Y * 0.25, soil.Size.Z * 1.01)
            rock.CFrame = soil.CFrame * CFrame.new(0, soil.Size.Y/2 - rock.Size.Y / 2.1, 0)

            soil.Parent = rockGroup
            rock.Parent = rockGroup
            rockGroup.Parent = workspace.Tmp.Vfx.Rocks

            if ray.Instance.Material == Enum.Material.Concrete or ray.Instance.Material == Enum.Material.Air or ray.Instance.Material == Enum.Material.Wood or ray.Instance.Material == Enum.Material.Neon or ray.Instance.Material == Enum.Material.WoodPlanks then
                soil.Material = ray.Instance.Material
                rock.Material = ray.Instance.Material
            else
                soil.Material = Enum.Material.Concrete
                rock.Material = ray.Instance.Material
            end

            soil.BrickColor = BrickColor.new("Dark grey") --ray.Instance.BrickColor
            soil.Anchored = true
            soil.CanTouch = false
            soil.CanCollide = false

            rock.BrickColor = ray.Instance.BrickColor
            rock.Anchored = true
            rock.CanTouch = false
            rock.CanCollide = false

            Promise.delay(rocksDuration):finally(function()
                local easyingStyle = Enum.EasingStyle.Quad
                local easingDirection = Enum.EasingDirection.InOut
                local tweenSoil = TweenService:Create(
                    soil,
                    TweenInfo.new(0.5, easyingStyle, easingDirection),
                    {Size = Vector3.new(.01, .01, .01)}
                )
                local tweenRock = TweenService:Create(
                    rock,
                    TweenInfo.new(0.5, easyingStyle, easingDirection),
                    {
                        CFrame = soil.CFrame * CFrame.new(0, soil.Size.Y/2 - soil.Size.Y / 2.1, 0),
                        Size = Vector3.new(.01, .01, .01),
                    }
                )
                tweenSoil:Play()
                tweenRock:Play()
                Promise.delay(0.5):finally(function()
                    tweenSoil:Destroy()
                    tweenRock:Destroy()
                end)
            end)
        end
    end

    return self
end

function Rocks:createDoubleCircle(position, distanceFromCenter, size, raycastParams, kwargs)
    self:createSimpleCircle(position, distanceFromCenter, size, raycastParams, kwargs)
    self:createSimpleCircle(position, math.sqrt(2) * distanceFromCenter, size, raycastParams, kwargs)

    return self
end

function Rocks:Destroy()
    self._maid:Destroy()
end

return Rocks