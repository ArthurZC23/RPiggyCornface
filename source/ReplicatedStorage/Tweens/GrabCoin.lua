local TweenService = game:GetService("TweenService")

local UNIT_VECTOR_Y = Vector3.new(0, 1, 0)
local Y_ROTATION = CFrame.Angles(0, math.pi, 0)

local module = {}

function module.play(part, kwargs)
    local yOffset = kwargs.yOffset
    local duration = kwargs.duration or 1
	local goal = {
        CFrame=part.CFrame * Y_ROTATION + yOffset * UNIT_VECTOR_Y,
        Size = 2 * part.Size,
        Transparency = 1
    }
	local tweenInfoUp = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local tween = TweenService:Create(part, tweenInfoUp, goal)
    tween:Play()

    return tween
end



return module