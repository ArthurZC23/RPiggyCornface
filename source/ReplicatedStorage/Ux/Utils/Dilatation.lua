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
    kwargs = kwargs or {}
    local expandFactor = kwargs.expandFactor or DEFAULT_EXPAND_FACTOR
    local tweenInfo = kwargs.tweenInfo or defaultTweenInfo
    local scale = {
        expandFactor.X * originalSize.X.Scale,
        expandFactor.Y * originalSize.Y.Scale,
    }
    local sizeGoal = UDim2.fromScale(unpack(scale))
    local goal = {Size = sizeGoal}
    local tween = TweenService:Create(
        guiObj,
        tweenInfo,
        goal
    )
    tween:Play()
    return tween
end

function module.shrink(guiObj, originalSize, kwargs)
    kwargs = kwargs or {}
    local tweenInfo = kwargs.tweenInfo or defaultTweenInfo
    local goal = {Size = originalSize}
    local tween = TweenService:Create(
        guiObj,
        tweenInfo,
        goal
    )
    tween:Play()
    return tween
end

return module