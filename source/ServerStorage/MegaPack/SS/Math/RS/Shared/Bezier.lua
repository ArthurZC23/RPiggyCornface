local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Functional = Mod:find({"Functional"})
local Maid = Mod:find({"Maid"})

local Bezier = {}
Bezier.__index = Bezier
Bezier.className = "Bezier"

local function _lerp(p0, p1, t)
    return p0 + (p1 - p0) * t
end

function Bezier:randomCubicBezierGenerator(p0, p3)
    local alpha1 = self.randoms.cubic:Next(0.05, 0.95)
    local alpha2 = self.randoms.cubic:Next(0.05, 0.95)
    local p1 = _lerp(p0, p3, alpha1)
    local p2 = _lerp(p1, p3, alpha2)
    return function (t)
        return Bezier.cubicBezier(t, p0, p1, p2, p3)
    end
end

function Bezier.lerp(p0, p1, t)
	return _lerp(p0, p1, t)
end

function Bezier.quad(t, p0, p1, p2)
	local l1 = _lerp(p0, p1, t)
	local l2 = _lerp(p1, p2, t)
	local quad = _lerp(l1, l2, t)
    return quad

	-- return ((1 - t) ^ 2) * p0 + 2 * (1 - t) * t * p1 + (t ^ 2) * p2
end

function Bezier.quadSaturated(t, p0, p1, p2)
    local _t = math.min(t, 1)
    local l1 = _lerp(p0, p1, _t)
    local l2 = _lerp(p1, p2, _t)
    local quad = _lerp(l1, l2, _t)
    return quad

	-- return ((1 - t) ^ 2) * p0 + 2 * (1 - t) * t * p1 + (t ^ 2) * p2
end

function Bezier.cubic(t, p0, p1, p2, p3)
	local l1 = _lerp(p0, p1, t)
	local l2 = _lerp(p1, p2, t)
	local l3 = _lerp(p2, p3, t)
	local a = _lerp(l1, l2, t)
	local b = _lerp(l2, l3, t)
	local cubic = _lerp(a, b, t)
	return cubic

    -- return ((1 - t) ^ 3 ) * p0 + 3 * ((1 - t) ^ 2) * t * p1 + 3 * (1 - t) * (t ^ 2) * p2 + (t ^ 3) * p3
end

function Bezier.cubicSaturated(t, p0, p1, p2, p3)
    local _t = math.min(t, 1)
	local l1 = _lerp(p0, p1, _t)
	local l2 = _lerp(p1, p2, _t)
	local l3 = _lerp(p2, p3, _t)
	local a = _lerp(l1, l2, _t)
	local b = _lerp(l2, l3, _t)
	local cubic = _lerp(a, b, _t)
	return cubic

    -- return ((1 - t) ^ 3 ) * p0 + 3 * ((1 - t) ^ 2) * t * p1 + 3 * (1 - t) * (t ^ 2) * p2 + (t ^ 3) * p3
end

function Bezier.new(curveType, points, kwargs)
    local self = {
        _maid = Maid.new(),
        randoms = {
            cubic = Random.new(),
        },
        points = points,
    }
    kwargs = kwargs or {}
    kwargs.debugger = kwargs.debugger or {}
    setmetatable(self, Bezier)

    assert(Bezier[curveType], ("Curve type %s doesn't exist."):format(curveType))

    local _curveFunc = Bezier[curveType]
    self.curve =  function(t)
        return _curveFunc(t, unpack(Functional.map(self.points, function(p)
            if typeof(p) == "Vector3" then
                return p
            elseif p:IsA("BasePart") then
                return p.Position
            else
                error(("Instance p is not valid"):format(p:GetFullName()))
            end
        end)))
    end

    if RunService:IsStudio() then
        task.defer(self.runDebugger, self, kwargs.debugger, _curveFunc)
    end

    return self
end

function Bezier:runDebugger(debugger, _curveFunc)
    local BezierFolder = workspace:FindFirstChild("BezierDebug")
    if not BezierFolder then
        BezierFolder = GaiaShared.create("Folder", {
            Name = "BezierDebug",
            Parent = workspace,
        })
    end

    if debugger.d3 then
        local pointProto = self._maid:Add(GaiaShared.create("Part", {
            Anchored = true,
            CastShadow = false,
            CanCollide = false,
            Color = Color3.fromRGB(200, 200, 0),
            Size = Vector3.new(1, 1, 1),
            Transparency = 0.5,
        }))
        local numPoints = #self.points
        for i, p in ipairs(self.points) do
            local point = self._maid:Add(pointProto:Clone())
            if typeof(p) == "Vector3" then
                point.Position = p
            elseif typeof(p) == "Instance" and p:IsA("BasePart") then
                point.Position = p.Position
            end
            if i == 1 or i == numPoints then
                point.Color = Color3.fromRGB(0, 255, 0)
            else
                point.Color = Color3.fromRGB(255, 0, 0)
            end
        end
        local framePoints = {}
        self._maid:Add(RunService.Heartbeat:Connect(function()
            for i, p in ipairs(framePoints) do
                p:Destroy()
            end
            framePoints = {}
            local curve =  function(t)
                return _curveFunc(t, unpack(Functional.map(self.points, function(p)
                    if typeof(p) == "Vector3" then
                        return p
                    elseif p:IsA("BasePart") then
                        return p.Position
                    else
                        error(("Instance p is not valid"):format(p:GetFullName()))
                    end
                end)))
            end
            local step = 0.1
            for t = 0, 1, step do
                if t == 0 or t == 1 then continue end
                local point = self._maid:Add(pointProto:Clone())
                point.Name = t / step
                point.Position = curve(t)
                point.Parent = BezierFolder
                table.insert(framePoints, point)
            end
        end))
    end

end

function Bezier:Destroy()

end

return Bezier