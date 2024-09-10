local TweenService = game:GetService("TweenService")

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local root = gui.Root
local fader = root.Fader
local loadingScreen = root.LoadingScreen
local gameLogo = loadingScreen.GameLogo
local gameLogo_2 = loadingScreen.GameLogo_2
local leftBanner = loadingScreen.LeftBanner
local rightBanner = loadingScreen.RightBanner
local lBar = loadingScreen.LoadingBar.LoadingBar

local function reduce(array, reducer, kwargs)
	kwargs = kwargs or {}
	local start = kwargs.start or 1
	local finish = kwargs.finish or #array
	local acumulator = kwargs.acc0 or array[start]
	for i=start+1,finish do
		acumulator = reducer(acumulator, array[i])
	end
	return acumulator
end

local function boolReduce(acc, v)
    return acc and v
end

local module = {}

function module.load(t, percentage, callback)
    local tweenInfo = TweenInfo.new(
        t,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.InOut,
        0,
        false,
        0
    )

    local finishes = {}
    for i=1,4 do
        finishes[i] = false
    end

    local tween1 = TweenService:Create(
        gameLogo.UIGradient,
        tweenInfo,
        {Offset=Vector2.new(0, -percentage)}
    )
    tween1:Play()

    tween1.Completed:Connect(function()
        finishes[1] = true
        if reduce(finishes, boolReduce) then
            callback()
        end
    end)

    local tween2 = TweenService:Create(
        leftBanner.UIGradient,
        tweenInfo,
        {Offset=Vector2.new(0, percentage)}
    )
    tween2:Play()

    tween2.Completed:Connect(function()
        finishes[2] = true
        if reduce(finishes, boolReduce) then
            callback()
        end
    end)

    local tween3 = TweenService:Create(
        rightBanner.UIGradient,
        tweenInfo,
        {Offset=Vector2.new(0, percentage)}
    )
    tween3:Play()

    tween3.Completed:Connect(function()
        finishes[3] = true
        if reduce(finishes, boolReduce) then
            callback()
        end
    end)

    local tween4 = TweenService:Create(
        lBar,
        tweenInfo,
        {Size=UDim2.fromScale(percentage, lBar.Size.Y.Scale)}
    )
    tween4:Play()
    tween4.Completed:Connect(function()
        finishes[4] = true
        if reduce(finishes, boolReduce) then
            callback()
        end
    end)

    -- local tween5 = TweenService:Create(
    --     gameLogo_2.UIGradient,
    --     tweenInfo,
    --     {Offset=Vector2.new(0, -percentage)}
    -- )
    -- tween5:Play()

    -- tween5.Completed:Connect(function()
        -- finishes[5] = true
        -- if reduce(finishes, boolReduce) then
        --     callback()
        -- end
    -- end)
end

function module.waitForGameToLoad(timeout)
    local t = 0
    while t < timeout and not game:IsLoaded() do
        local step = task.wait()
        t = t + step
    end
end

function module.fadeIn(t)
    local tweenInfo = TweenInfo.new(
        t,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    local tween = TweenService:Create(
        fader,
        tweenInfo,
        {BackgroundTransparency=1}
    )
    tween:Play()
    tween.Completed:Wait()
end

function module.fadeOut(t)
    local tweenInfo = TweenInfo.new(
        t,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    local tween = TweenService:Create(
        fader,
        tweenInfo,
        {BackgroundTransparency=0}
    )
    tween:Play()
    tween.Completed:Wait()
end

function module.clearLoadingScreen(root)
    for _, child in ipairs(root:GetChildren()) do
        if child == fader then continue end
        child:Destroy()
    end
end



return module