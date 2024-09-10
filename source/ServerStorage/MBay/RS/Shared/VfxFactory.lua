local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TweenGroup = Mod:find({"Tween", "TweenGroup"})
local TweenFactory = Mod:find({"Tween", "TweenFactory"})
local Functional = Mod:find({"Functional"})
local TableUtils = Mod:find({"Table", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local InstanceUtils = Mod:find({"InstanceUtils", "Utils"})
local InstanceProps = Mod:find({"InstanceUtils", "Props"})
local Maid = Mod:find({"Maid"})

local module = {}

function module._createShell(model, transform, kwargs)
    kwargs = kwargs or {}
    local scale = kwargs.scale or 1.05
    local shellArray = Functional.filterThenMap(
        model:GetDescendants(),
        function(desc)
            if desc:IsA("BasePart") and desc.Transparency ~= 1 then return true end
        end,
        function(desc)
            local root = workspace.Tmp.Combat
            local clone = desc:Clone()
            InstanceUtils.clearChildrenWhichAreNot(clone, {"SpecialMesh"})
            for _, child in ipairs(clone:GetChildren()) do
                if InstanceProps.hasTexture(child) then
                    InstanceProps.setTexture(child, "")
                    child.Scale = scale * child.Scale
                end
            end
            TableUtils.setInstance(
                clone,
                {
                    Anchored = false,
                    CanCollide = false,
                    CanTouch = false,
                    CanQuery = false,
                    Massless = true,
                    Size = scale * desc.Size,
                    Parent = root,
                }
            )
            transform(clone)
            GaiaShared.create("WeldConstraint", {
                Part0 = clone,
                Part1 = desc,
                Parent = clone,
            })
            return clone
        end
    )
    return shellArray
end

function module._createShellWithOutline(outline, charProps, kwargs)
    local maid = Maid.new()
    local prop = charProps.props[outline]
    if not prop then return maid end
    maid:Add(function()
        prop:removeCause("FillColor", kwargs.cause)
        prop:removeCause("FillTransparency", kwargs.cause)
        prop:removeCause("OutlineColor", kwargs.cause)
        prop:removeCause("OutlineTransparency", kwargs.cause)
    end)
    prop:set("FillColor", kwargs.cause, kwargs.FillColor)
    prop:set("FillTransparency", kwargs.cause, kwargs.FillTransparency)
    prop:set("OutlineColor", kwargs.cause, kwargs.OutlineColor)
    prop:set("OutlineTransparency", kwargs.cause, kwargs.OutlineTransparency)
    return maid
end

local function _getShellCleanupTweens(array, tweenInfo, goal)
    local tweens = Functional.filterThenMap(
        array,
        function(desc)
            return true
        end,
        function(clone)
            local tween = TweenService:Create(clone, tweenInfo, goal(clone))
            return tween
        end
    )
    return tweens
end

function module.createShell(model, transform, tweenInfo, goal, kwargs)
    kwargs = kwargs or {}
    local shellArray = module._createShell(model, transform, kwargs)
    local tweens = _getShellCleanupTweens(shellArray, tweenInfo, goal)
    local tweenGroup = TweenGroup.new(tweens)
    tweenGroup:AllCompletedOnce():finally(function()
        for _, tween in pairs(tweens) do
            tween.Instance:Destroy()
        end
    end)
    tweenGroup:Play()
end

function module.getShellTweenGroup(model, transform, tweenInfo, goal, kwargs)
    kwargs = kwargs or {}
    local shellArray = module._createShell(model, transform, kwargs)
    local tweenGroup = TweenGroup.new(_getShellCleanupTweens(shellArray, tweenInfo, goal))
    return tweenGroup
end

function module.setModelColorV1(model, color, tweenInfo)
    local originalProps = { }
    local tweens = TweenFactory.createDescendantsTweens(
        model,
        tweenInfo,
        {Color = color,},
        function(desc)
            if desc:IsA("Decal") or desc:IsA("Texture") then
                originalProps[desc] = {
                    Color = desc.Color,
                    Transparency = desc.Transparency,
                }
                desc.Transparency = 1
                return true
            elseif desc:IsA("SpecialMesh") then
                originalProps[desc] = {
                    Color = desc.Color,
                    TextureId = desc.TextureId,
                }
                desc.TextureId = ""
                return true
            elseif desc:IsA("MeshPart") then
                originalProps[desc] = {
                    Color = desc.Color,
                    TextureId = desc.TextureId,
                }
                desc.TextureID = ""
                return true
            elseif desc:IsA("BasePart") then
                originalProps[desc] = {
                    Color = desc.Color,
                    TextureId = desc.TextureId,
                }
                return true
            end
        end
    )
    local tweenGroup = TweenGroup.new(tweens)
    tweenGroup:Play()
end

return module