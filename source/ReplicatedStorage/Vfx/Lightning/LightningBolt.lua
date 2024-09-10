local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Bezier = Mod:find({"Math", "Bezier"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local clock = os.clock
local xInverse = CFrame.lookAt(Vector3.new(), Vector3.new(1, 0, 0)):Inverse()
local offsetAngle = math.cos(math.rad(90))
local ActiveBranches = {}

local LightningBolt = {}
LightningBolt.__index = LightningBolt
LightningBolt.className = "LightningBolt"

local partProto = GaiaShared.create("Part", {
    Shape = Enum.PartType.Cylinder,
    Material = Enum.Material.Neon,
    Color = Color3.fromRGB(255, 255, 255),
    Anchored = true,
    CastShadow = false,
    CanCollide = false,
    CanTouch = false,
    Locked = true,
    Position = Vector3.new(1e10, 1e10, 1e10),
    Size = Vector3.new(1, 1, 1),
    Transparency = 1,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
})

local function DiscretePulse(percentage, s, k, f, t, min, max)
    --0 <= percentage <= 1. See https://www.desmos.com/calculator/hg5h4fpfim.
	return math.clamp(
        (k / (2*f)) - math.abs((percentage - t * s + 0.5 * k) / f ),
        min,
        max
    )
end

local function NoiseBetween(x, y, z, min, max)
    return min + (max - min) * (math.noise(x, y, z) + 0.5)
end

local function CubicBezier(p0, p1, p2, p3, t)
	return p0*(1 - t)^3 + p1*3*t*(1 - t)^2 + p2*3*(1 - t)*t^2 + p3*t^3
end

function LightningBolt.new(Attachment0, Attachment1, kwargs)
    kwargs = kwargs or {}
    local self = {
        _maid = Maid.new(),
        Parts = {},
        -- Bolt Appearance Properties
        Enabled = true, --Hides bolt without destroying any parts when false
        Attachment0 = Attachment0, --Bolt originates from Attachment0 and ends at Attachment1
        Attachment1 = Attachment1,
        CurveSize0 = 0, --Works similarly to beams. See https://dk135eecbplh9.cloudfront.net/assets/blt160ad3fdeadd4ff2/BeamCurve1.png
        CurveSize1 = 0,
        MinRadius = 0, --Governs the amplitude of fluctuations throughout the bolt
        MaxRadius = 2.4,
        Frequency = 2, --Governs the frequency of fluctuations throughout the bolt. Lower this to remove jittery-looking lightning
        AnimationSpeed = 7, --Governs how fast the bolt oscillates (i.e. how fast the fluctuating wave travels along bolt)
        Thickness = 1, --The thickness of the bolt
        MinThicknessMultiplier = 0.2, --Multiplies Thickness value by a fluctuating random value between MinThicknessMultiplier and MaxThicknessMultiplier along the Bolt
        MaxThicknessMultiplier = 1,
        --Bolt Kinetic Properties

        --Allows for fading in (or out) of the bolt with time. Can also create a "projectile" bolt
        --Recommend setting AnimationSpeed to 0 if used as projectile (for better aesthetics)
        --Works by passing a "wave" function which travels from left to right where the wave height represents opacity (opacity being 1 - Transparency)
        --See https://www.desmos.com/calculator/hg5h4fpfim to help customise the shape of the wave with the below properties

        MinTransparency = 0, --See https://www.desmos.com/calculator/hg5h4fpfim
        MaxTransparency = 1,
        PulseSpeed = 10, --Bolt arrives at Attachment1 1/PulseSpeed seconds later. See https://www.desmos.com/calculator/hg5h4fpfim
        PulseLength = 1000000, --See https://www.desmos.com/calculator/hg5h4fpfim
        FadeLength = 0.2, --See https://www.desmos.com/calculator/hg5h4fpfim
        ContractFrom = 0.5, --Parts shorten or grow once their Transparency exceeds this value. Set to a value above 1 to turn effect off. See https://imgur.com/OChA441

        Color = Color3.new(1, 1, 1), --Can be a Color3 or ColorSequence
		ColorOffsetSpeed = 3, --Sets speed at which ColorSequence travels along Bolt

        PartsHidden = false,
        DisabledTransparency = true,
        StartT = clock(),
        RanNum = 100 * Random.new():NextNumber(),
    }
    setmetatable(self, LightningBolt)

    local partCount = kwargs.partCount or 30
    self:createParts(partCount)

    ActiveBranches[self] = true
    self._maid:Add(function()
        ActiveBranches[self] = nil
        for i, part in ipairs(self.Parts) do
            part:Destroy()
            if i % 100 == 0 then task.wait() end
        end
    end)

    return self
end

function LightningBolt:createParts(partCount)
    local Parent = workspace.Tmp.Vfx.Lightning
    local p0 = self.Attachment0.WorldPosition
    local p3 = self.Attachment1.WorldPosition
    local p1 = p0 * (1 + self.CurveSize0)
    local p2 = p3 * (1 - self.CurveSize1)
    local PrevPoint = p0
    local bezier0 = p0

    for i = 1, partCount do
		local t1 = i/partCount
		local bezier1 = CubicBezier(p0, p1, p2, p3, t1)
        local NextPoint
        -- local NextPoint = i ~= partCount and (CFrame.lookAt(bezier0, bezier1)).Position or bezier1
        if i < partCount then
            NextPoint = bezier0
        else
            NextPoint = bezier1
        end
		local BPart = partProto:Clone()
		BPart.Size = Vector3.new((NextPoint - PrevPoint).Magnitude, 0, 0)
		BPart.CFrame = CFrame.lookAt(0.5 * (PrevPoint + NextPoint), NextPoint) * xInverse
		BPart.Parent = Parent
		self.Parts[i] = BPart
		PrevPoint, bezier0 = NextPoint, bezier1
	end
end

-- Stopped here. Need to reviw code. Didn't touch on the other lighthing modules
function LightningBolt:frameExecution()
    for _, ThisBranch in pairs(ActiveBranches) do
		if ThisBranch.Enabled == true then
            ThisBranch.PartsHidden = false
            local MinOpa, MaxOpa = 1 - ThisBranch.MaxTransparency, 1 - ThisBranch.MinTransparency
            local MinRadius, MaxRadius = ThisBranch.MinRadius, ThisBranch.MaxRadius
			local thickness = ThisBranch.Thickness
			local Parts = ThisBranch.Parts
			local PartsN = #Parts
			local RanNum = ThisBranch.RanNum
			local StartT = ThisBranch.StartT
			local spd = ThisBranch.AnimationSpeed
			local freq = ThisBranch.Frequency
			local MinThick, MaxThick = ThisBranch.MinThicknessMultiplier, ThisBranch.MaxThicknessMultiplier
			local a0, a1, CurveSize0, CurveSize1 = ThisBranch.Attachment0, ThisBranch.Attachment1, ThisBranch.CurveSize0, ThisBranch.CurveSize1
            local p0 = self.Attachment0.WorldPosition
            local p3 = self.Attachment1.WorldPosition
            local p1 = p0 * (1 + self.CurveSize0)
            local p2 = p3 * (1 - self.CurveSize1)
            local timePassed = clock() - StartT
			local PulseLength, PulseSpeed, FadeLength = ThisBranch.PulseLength, ThisBranch.PulseSpeed, ThisBranch.FadeLength
			local Color = ThisBranch.Color
			local ColorOffsetSpeed = ThisBranch.ColorOffsetSpeed
			local contractf = 1 - ThisBranch.ContractFrom
			local PrevPoint, bezier0 = p0, p0

            if timePassed < (PulseLength + 1) / PulseSpeed then
                for i = 1, PartsN do
                    local BPart = Parts[i]
					local t1 = i/PartsN
                    local Opacity = DiscretePulse(t1, PulseSpeed, PulseLength, FadeLength, timePassed, MinOpa, MaxOpa)
                    local bezier1 = CubicBezier(p0, p1, p2, p3, t1)
					local time = -timePassed --minus to ensure bolt waves travel from a0 to a1
                    local input = (spd * time) + freq * 10 * t1 - 0.2 + RanNum * 4
                    local input2 = 5 * ((spd * 0.01 * time) / 10 + freq * t1) + RanNum * 4
                    local noise0 = NoiseBetween(5 * input, 1.5, input2, 0, 0.1 * 2 *math.pi) + NoiseBetween(0.5 * input, 1.5, 0.5 * 0.2 * input2, 0, 0.9 * 2 * math.pi)
					local noise1 = NoiseBetween(3.4, input2, input, MinRadius, MaxRadius) * math.exp(-5000 * (t1 - 0.5) ^ 10)
                    local thicknessNoise = NoiseBetween(2.3, input2, input, MinThick, MaxThick)
                    local NextPoint
                    if i < PartsN then
                        NextPoint =
                            (CFrame.new(bezier0, bezier1)
                            * CFrame.Angles(0, 0, noise0)
                            * CFrame.Angles(
                                math.acos(
                                    math.clamp(
                                        NoiseBetween(input2, input, 2.7, offsetAngle, 1), 
                                        -1,
                                        1
                                    )
                                ),
                                0,
                                0
                            ) * CFrame.new(0, 0, -noise1)).Position
                    else
                        NextPoint = bezier1
                    end

                    if Opacity > contractf then
						BPart.Size = Vector3.new((NextPoint - PrevPoint).Magnitude, thickness * thicknessNoise * Opacity, thickness * thicknessNoise * Opacity)
						BPart.CFrame = CFrame.lookAt(0.5*(PrevPoint + NextPoint), NextPoint)*xInverse
						BPart.Transparency = 1 - Opacity
                    elseif Opacity > contractf - 1/(PartsN*FadeLength) then
						local interp = (1 - (Opacity - (contractf - 1/(PartsN*FadeLength)))*PartsN*FadeLength)*(t1 < timePassed*PulseSpeed - 0.5*PulseLength and 1 or -1)
						BPart.Size = Vector3.new((1 - math.abs(interp))*(NextPoint - PrevPoint).Magnitude, thickness*thicknessNoise*Opacity, thickness*thicknessNoise*Opacity)
						BPart.CFrame = CFrame.lookAt(PrevPoint + (NextPoint - PrevPoint)*(math.max(0, interp) + 0.5*(1 - math.abs(interp))), NextPoint)*xInverse
						BPart.Transparency = 1 - Opacity
                    else
                        BPart.Transparency = 1
                    end

                end
            else
                ThisBranch:Destroy()
            end
        else
            if ThisBranch.PartsHidden == false then
				ThisBranch.PartsHidden = true
				local datr = ThisBranch.DisabledTransparency
				for i = 1, #ThisBranch.Parts do
					ThisBranch.Parts[i].Transparency = datr
				end
			end
			
        end
    end
end

function LightningBolt:Destroy()
    self._maid:Destroy()
end

return LightningBolt