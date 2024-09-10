local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local module = {}

module.fadeIns = {}

function module.fadeIns.frame (frame, duration)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local tween = TweenService:Create(
        frame,
        tweenInfo,
        {BackgroundTransparency=1}
    )
    tween:Play()
    return tween
end

module.imageMaskData = {
    MAX_SIZE = 4,
    MIN_SIZE = 0.1,
    STEP = 0.12,
}

function module.fadeIns.imageMask (fadeMask, hBorders, vBorders)
    local MAX_SIZE = module.imageMaskData.MAX_SIZE
    local STEP = module.imageMaskData.STEP

    while fadeMask.Size.X.Scale < MAX_SIZE do
		RunService.Heartbeat:Wait()
		fadeMask.Size = UDim2.fromScale(fadeMask.Size.X.Scale + STEP, fadeMask.Size.Y.Scale + STEP)
		for _, frame in ipairs(hBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			frame.Size = UDim2.fromScale(math.max((1 - fadeMask.Size.X.Scale)/2, 0), 1)
		end
		for _, frame in ipairs(vBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			if frame.Name == "BorderT" then
				frame.Size = UDim2.fromScale(1, math.max(0.1 + (1 - fadeMask.Size.Y.Scale)/2, 0.1))
			else
				frame.Size = UDim2.fromScale(1, math.max((1 - fadeMask.Size.Y.Scale)/2, 0))
			end
		end
	end
end

module.fadeOuts = {}

function module.fadeOuts.frame (frame, duration)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local tween = TweenService:Create(
        frame,
        tweenInfo,
        {BackgroundTransparency=0}
    )
    tween:Play()
    return tween
end

function module.fadeOuts.imageMask (fadeMask, hBorders, vBorders)
    local MAX_SIZE = module.imageMaskData.MAX_SIZE
    local MIN_SIZE = module.imageMaskData.MIN_SIZE
    local STEP = module.imageMaskData.STEP

    fadeMask.Size = UDim2.fromScale(MAX_SIZE, MAX_SIZE)
    while fadeMask.Size.X.Scale > MIN_SIZE do
		RunService.Heartbeat:Wait()
		fadeMask.Size = UDim2.fromScale(fadeMask.Size.X.Scale - STEP, fadeMask.Size.Y.Scale - STEP)
		for _, frame in ipairs(hBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			frame.Size = UDim2.fromScale((1 - fadeMask.Size.X.Scale)/2, 1)
		end
		for _, frame in ipairs(vBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			if frame.Name == "BorderT" then
				frame.Size = UDim2.fromScale(1, 0.1 + (1 - fadeMask.Size.Y.Scale)/2)
			else
				frame.Size = UDim2.fromScale(1, (1 - fadeMask.Size.Y.Scale)/2)
			end
		end
    end
end

return module