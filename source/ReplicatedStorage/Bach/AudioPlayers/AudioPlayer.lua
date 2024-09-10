local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local Ap = {}
Ap.className = "AudioPlauer"
Ap.__index = Ap

function Ap:play(sound, kwargs)
	kwargs = kwargs or {}
    local soundProps = kwargs.soundProps or {}
    TableUtils.setInstance(sound, soundProps)
    if kwargs.fadeIn then
        local Volume = sound.Volume
        sound.Volume = 0
        local tweenInfo = TweenInfo.new(kwargs.fadeIn.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        local goal = {Volume = Volume}
        sound.Volume = 0
        local tween = TweenService:Create(sound, tweenInfo, goal)
        tween:Play()
        kwargs._maid:Add2(function()
            tween:Cancel()
            tween:Destroy()
            sound.Volume = Volume
        end, "FadeInTween")
    end
    sound:Play()
end

function Ap:pause(sound, kwargs)
    kwargs = kwargs or {}
    local soundProps = kwargs.soundProps or {}
    TableUtils.setInstance(sound, soundProps)
    sound:Pause()
end

function Ap:resume(sound, kwargs)
    kwargs = kwargs or {}
    local soundProps = kwargs.soundProps or {}
    TableUtils.setInstance(sound, soundProps)
    sound:Resume()
end

function Ap:stop(sound, kwargs)
    kwargs = kwargs or {}
    local soundProps = kwargs.soundProps or {}
    TableUtils.setInstance(sound, soundProps)
    -- if kwargs.fadeOut then
    --     local tweenInfo = TweenInfo.new(kwargs.fadeOut.duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
    --     local goal = {Volume = 0}
    --     local tween = TweenService:Create(sound, tweenInfo, goal)
    --     tween:Play()
    --     kwargs._maid:Add2(function()
    --         sound:Stop()
    --         tween:Cancel()
    --         tween:Destroy()
    --         sound.Volume = 0
    --     end, "FadeOutTween")
    -- else
    --     sound:Stop()
    -- end
    sound:Stop()
end

return Ap