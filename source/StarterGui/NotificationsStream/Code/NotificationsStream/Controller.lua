local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local Promise = Mod:find({"Promise", "Promise"})
local Bach = Mod:find({"Bach", "Bach"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local Containers = {
    BottomLeftFrame = {
        Root = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BottomLeftFrame"}),
    },
    TopCenter = {
        Root = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="TopCenter"}),
    },
    Tokens = {
        Root = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Tokens"}),
    },
}

for _, data in pairs(Containers) do
    data.NotificationProto = SharedSherlock:find({"EzRef", "Get"}, {inst=data.Root, refName="NotificationProto"})
    data.Container = data.NotificationProto.Parent
    data.NotificationProto.Parent = nil
end

local NotificationStreamSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="NotificationStream"})
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local DummyFrameProto = GaiaShared.create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(0, 0),
})

local Controller = {}
Controller.__index = Controller
Controller.className = "Controller"
Controller.TAG_NAME = Controller.className

function Controller.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Controller)

    self:handleNotifications()

    return self
end

function Controller:handleNotifications()
    local function onNotification(message, kwargs)
        kwargs = kwargs or {}
        self:addNotification(message, kwargs)
        :andThen(function(NotificationGui)
            if kwargs.sfx then
                Bach:play(kwargs.sfx.name, Bach.SoundTypes.SfxGui)
            end
            if kwargs.fadeOut then
                if kwargs.fadeOut.name == "TextExpansionFadeOut" then
                    for _ = 1, 1 do
                        Cronos.wait(1)
                        local clone = NotificationGui.TextLabel:Clone()
                        clone.ZIndex -= 1
                        clone.Parent = NotificationGui.TextLabel.Parent
                        local tweenInfo = TweenInfo.new(
                            1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
                        local tween = TweenService:Create(clone, tweenInfo, {
                            TextStrokeTransparency = 1,
                            TextTransparency = 1,
                            Size = UDim2.fromScale(1.2 * clone.Size.X.Scale, 1.2 * clone.Size.Y.Scale),
                        })
                        tween:Play()
                        tween.Completed:Connect(function()
                            clone:Destroy()
                        end)
                    end
                end
            end
        end)
    end
    NotificationStreamSE:Connect(onNotification)
    NotificationStreamRE.OnClientEvent:Connect(onNotification)
end

function Controller:addNotification(message, kwargs)
    local res = {}
    local fadeIn = kwargs.fadeIn or "allTextFadeIn"
    if fadeIn == "allTextFadeIn" then
        return Promise.try(function()
            local Root = kwargs.Root or "BottomLeftFrame"
            local NotificationProto = Containers[Root].NotificationProto
            local NotificationGui = NotificationProto:Clone()
            local Container = Containers[Root].Container
            NotificationGui.TextLabel.TextTransparency = 1
            NotificationGui.TextLabel.TextStrokeTransparency = 1

            TableUtils.setInstance(NotificationGui.TextLabel, message)
            NotificationGui.Visible = true
    
            local dummyFrame = DummyFrameProto:Clone()
            dummyFrame.Parent = Container
            local p1 = Promise.try(function()
                local tweenInfo = TweenInfo.new(
                    0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0)
                local tween = TweenService:Create(dummyFrame, tweenInfo, {
                    Size = NotificationProto.Size
                })
                tween:Play()
                tween.Completed:Wait()
            end)
            local p2 = Promise.try(function()
                NotificationGui.Position = dummyFrame.Position + UDim2.fromScale(0, 2)
                NotificationGui.Size = UDim2.fromOffset(
                    Container.AbsoluteSize.X * NotificationProto.Size.X.Scale,
                    Container.AbsoluteSize.Y * NotificationProto.Size.Y.Scale)
                NotificationGui.Parent = gui.Root
    
                local tweenInfo = TweenInfo.new(
                    0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, 0)
                local tween = TweenService:Create(NotificationGui, tweenInfo, {
                    Position = UDim2.fromOffset(NotificationGui.AbsolutePosition.X, NotificationGui.AbsolutePosition.Y)
                })
                tween:Play()
                tween.Completed:Wait()
            end)
            res.NotificationGui = NotificationGui
            res.dummyFrame = dummyFrame
            res.Container = Container
    
            return Promise.all({p1, p2})
        end)
        :andThen(function ()
            local NotificationGui = res.NotificationGui
            local dummyFrame = res.dummyFrame
            local Container = res.Container
    
            dummyFrame:Destroy()
            NotificationGui.Parent = Container
    
            local tweenInfo = TweenInfo.new(
                0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
            local tween = TweenService:Create(NotificationGui.TextLabel, tweenInfo, {
                TextStrokeTransparency = 0,
                TextTransparency = 0,
            })
            tween:Play()
            return Promise.fromEvent(tween.Completed)
        end)
        :andThen(function ()
            local NotificationGui = res.NotificationGui
            local lifetime = kwargs.lifetime or 10
            return Promise.delay(lifetime)
            :andThen(function ()
                local tweenInfo = TweenInfo.new(
                    1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
                local tween = TweenService:Create(NotificationGui.TextLabel, tweenInfo, {
                    TextStrokeTransparency = 1,
                    TextTransparency = 1,
                })
                tween:Play()
                tween.Completed:Wait()
                NotificationGui:Destroy()
                return NotificationGui
            end)
        end)
    end
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller.new()