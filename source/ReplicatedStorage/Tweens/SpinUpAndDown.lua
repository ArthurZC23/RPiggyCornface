local TweenService = game:GetService("TweenService")

local UNIT_VECTOR_Y = Vector3.new(0, 1, 0)
local Y_ROTATION = CFrame.Angles(0, math.pi, 0)

local module = {}

function module.play(part, kwargs)
    local yOffset = kwargs.yOffset
    local tweens = {}
	local initialCF = part.CFrame
	local goalUp = {CFrame=initialCF * Y_ROTATION + yOffset * UNIT_VECTOR_Y}
	local tweenInfoUp = TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
	tweens.up = TweenService:Create(part, tweenInfoUp, goalUp)

	local goalDown = {CFrame=initialCF}
	local tweenInfoDown = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
	tweens.down = TweenService:Create(part, tweenInfoDown, goalDown)

    tweens.up.Completed:Connect(function()
        if tweens.down then tweens.down:Play() end
	end)
    tweens.down.Completed:Connect(function()
        if tweens.up then tweens.up:Play() end
	end)
    tweens.up:Play()

    return tweens
end



return module