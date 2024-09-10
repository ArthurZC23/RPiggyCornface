local TweenService = game:GetService("TweenService")

local TWEEN_DURATION = 0.25
local DEFAULT_EXPAND_FACTOR = {
    X = 1.25,
    Y = 1.25,
}

local defaultTweenInfo = TweenInfo.new(
    TWEEN_DURATION,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut,
    0,
    false,
    0
)

local module = {}

function module.expand(guiObj, originalSize, kwargs)
    local EXPAND_FACTOR = kwargs.EXPAND_FACTOR or DEFAULT_EXPAND_FACTOR
    local tweenInfo = kwargs.tweenInfo or defaultTweenInfo
    local expandedSizeDim = {
        EXPAND_FACTOR.X * originalSize.X.Scale,
        EXPAND_FACTOR.X * originalSize.X.Offset,
        EXPAND_FACTOR.Y * originalSize.Y.Scale,
        EXPAND_FACTOR.Y * originalSize.Y.Offset,
    }
    local sizeGoal = UDim2.new(unpack(expandedSizeDim))
    local goal = {Size = sizeGoal}
    local tween = TweenService:Create(
        guiObj,
        tweenInfo,
        goal
    )
    tween:Play()
    tween.Completed:Connect(function() tween:Destroy() end)
end

function module.shrink(guiObj, originalSize, kwargs)
    local tweenInfo = kwargs.tweenInfo or defaultTweenInfo
    local goal = {Size = originalSize}
    local tween = TweenService:Create(
        guiObj,
        tweenInfo,
        goal
    )
    tween:Play()
    tween.Completed:Connect(function() tween:Destroy() end)
end

return module