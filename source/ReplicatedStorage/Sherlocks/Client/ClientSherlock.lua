local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Sherlock = Mod:find({"Sherlocks", "Sherlock"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PageManager = Mod:find({"Gui", "PageManager", "PageManager"})
local Functional = Mod:find({"Functional"})
local FunctionUtils = Mod:find({"Function", "Utils"})

local Blur = Lighting.Blur

if RunService:IsServer() then error("Client module") end

local player = Players.LocalPlayer
local PlayerGui  = player:WaitForChild("PlayerGui")
local ButtonsGui = PlayerGui:WaitForChild("Buttons")

local hideableGui = Functional.filter(ButtonsGui.Root:GetDescendants(), function(desc)
    if not CollectionService:HasTag(desc, "GuiComponent") then return false end
    if desc:GetAttribute("showWhileMainGuiIsOpen") then return false end
    return true
end)

local searchSpace = {
    ["Module"] = {

    },
    ["Gui"] = function(kwargs)
        local refName = kwargs.refName
        local gui = kwargs.gui
        if not gui then
            local guiName = kwargs.guiName
            gui = PlayerGui:WaitForChild(guiName)
        end
        local References = gui:FindFirstChild("References")
        if not References then
            References = gui.Code.References
        end
        local reference = References:WaitForChild(("%s"):format(refName))
        return reference.Value
    end,
    PageManager = {
        FrontPage = FunctionUtils.computeOnce(
            function()

                --local tweenDuration = 0.75
                local tweenDuration = 0.25
                local tweenInfoBlur = TweenInfo.new(
                    tweenDuration,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out,
                    0,
                    false,
                    0
                )
                local tweenInfoGuiEnter = TweenInfo.new(
                    tweenDuration,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out,
                    0,
                    false,
                    0
                )
                local tweenInfoGuiExit = TweenInfo.new(
                    tweenDuration,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.In,
                    0,
                    false,
                    0
                )

                local positionOffset = {-0.4, 0.4}
                local size0 = {0.1, 0.1}
                local rotationOffset = 0

                return PageManager.new("FrontPage", {
                    exitEffect = function()
                        local tween = TweenService:Create(
                            Blur,
                            tweenInfoBlur,
                            {Size=0}
                        )
                        tween.Completed:Connect(function()
                            Functional.map(hideableGui, function(_gui)
                                if _gui:GetAttribute("teamGui") then
                                    local team = player:GetAttribute("team")
                                    if team == _gui:GetAttribute("teamGui") then
                                        _gui.Visible = true
                                    end
                                else
                                    _gui.Visible = true
                                end
                                return _gui
                            end)
                        end)
                        tween:Play()
                        player.CameraMinZoomDistance = 0.5
                        --pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end)
                    end,
                    openEffect = function()
                        --pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end)
                        do
                            Functional.map(hideableGui, function(_gui)
                                _gui.Visible = false
                                return hideableGui
                            end)
                        end
                        player.CameraMinZoomDistance = 1
                        -- local tween = TweenService:Create(
                        --     Blur,
                        --     tweenInfoBlur,
                        --     {Size=15}
                        -- )
                        -- tween:Play()
                    end,
                    guiEnter = function(gui)
                        -- local position = gui.Position
                        -- local rotation = gui.Rotation
                        -- local size = gui.Size
                        -- gui.Position = position + UDim2.fromScale(unpack(positionOffset))
                        -- gui.Size = UDim2.fromScale(unpack(size0))
                        -- gui.Rotation = rotationOffset
                        -- local tween = TweenService:Create(
                        --     gui,
                        --     tweenInfoGuiEnter,
                        --     {
                        --         Position = position,
                        --         Rotation = rotation,
                        --         Size = size,
                        --     }
                        -- )
                        gui.Visible = true
                        -- tween:Play()
                        -- tween.Completed:Wait()
                    end,
                    guiLeave = function(gui)
                        -- local position = gui.Position
                        -- local rotation = gui.Rotation
                        -- local size = gui.Size
                        -- local tween = TweenService:Create(
                        --     gui,
                        --     tweenInfoGuiExit,
                        --     {
                        --         Position = position + UDim2.fromScale(unpack(positionOffset)),
                        --         Rotation = rotationOffset,
                        --         Size = UDim2.fromScale(unpack(size0)),
                        --     }
                        -- )
                        -- tween:Play()
                        -- tween.Completed:Wait()
                        gui.Visible = false
                        -- gui.Position = position
                        -- gui.Rotation = rotation
                        -- gui.Size = size
                    end,
                })
            end
        ),
        Shop = FunctionUtils.computeOnce(
            function()
                return PageManager.new("Shop", {
                    exitEffect = function()
                    end,
                    openEffect = function()

                    end,
                    guiEnter = function(gui)
                        gui.Visible = true
                    end,
                    guiLeave = function(gui)
                        gui.Visible = false
                    end,
                })
            end
        ),
        BecomeMonster = FunctionUtils.computeOnce(
            function()
                return PageManager.new("BecomeMonster", {
                    exitEffect = function()
                    end,
                    openEffect = function()

                    end,
                    guiEnter = function(gui)
                        gui.Visible = true
                    end,
                    guiLeave = function(gui)
                        gui.Visible = false
                    end,
                })
            end
        ),
        SpinWheel = FunctionUtils.computeOnce(
            function()
                return PageManager.new("SpinWheel", {
                    exitEffect = function()
                    end,
                    openEffect = function()

                    end,
                    guiEnter = function(gui)
                        gui.Visible = true
                    end,
                    guiLeave = function(gui)
                        gui.Visible = false
                    end,
                })
            end
        ),
        Boosts = FunctionUtils.computeOnce(
            function()
                return PageManager.new("Boosts", {
                    exitEffect = function()

                    end,
                    openEffect = function()

                    end,
                    guiEnter = function(gui)
                        gui.Visible = true
                    end,
                    guiLeave = function(gui)
                        gui.Visible = false
                    end,
                })
            end
        ),
        Inventory = FunctionUtils.computeOnce(
            function()
                return PageManager.new("Inventory", {
                    exitEffect = function()
                    end,
                    openEffect = function()
                    end,
                    guiEnter = function(gui)
                        gui.Visible = true
                    end,
                    guiLeave = function(gui)
                        gui.Visible = false
                    end,
                })
            end
        ),
        Avatar = FunctionUtils.computeOnce(
            function()
                return PageManager.new("Avatar", {
                    exitEffect = function()
                    end,
                    openEffect = function()
                    end,
                    guiEnter = function(gui)
                        gui.Visible = true
                    end,
                    guiLeave = function(gui)
                        gui.Visible = false
                    end,
                })
            end
        ),
    }
}

return Sherlock.new(searchSpace)