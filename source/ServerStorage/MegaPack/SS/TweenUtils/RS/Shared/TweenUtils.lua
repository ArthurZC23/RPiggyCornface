local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Vectors = Data.Physics.Vectors
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})

local TweenUtils = {}
TweenUtils.__index = TweenUtils

function TweenUtils.new()
    local self = {}
    setmetatable(self, TweenUtils)
    return self
end

function TweenUtils.createRunAndWait(obj, tweenInfo, props)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    tween.Completed:Wait()
end

function TweenUtils.applyAtTheEndPromise(tween, props)
    local prom = Promise.new(function(resolve, _, onCancel)

        if onCancel(function()
            tween:Cancel()
            TableUtils.setInstance(tween, props)
        end) then return end

        tween:Play()
        tween.Completed:Wait()
        resolve()
    end)
    return prom
end

-- Use SizeUtils
local CFrameUtils = Mod:find({"Mosby", "CFrameUtils"})
function TweenUtils.DilateSurfaceTween(part, tweenInfo, surface, size1D)
    local dilatationDirection = CFrameUtils.getSurface[surface](part)
    local axis
    if surface == "top" or surface == "bottom" then
        axis = "Y"
    elseif surface == "right" or surface == "left" then
        axis = "X"
    elseif surface == "back" or surface == "front" then
        axis = "Z"
    end
    local deltaL = size1D - part.Size[axis]
    local goal = {
        Position=part.Position + (deltaL/2) * dilatationDirection,
        Size=
            part.Size * (Vector3.new(1, 1, 1) - Vectors.unit[axis])
            + size1D * Vectors.unit[axis]
    }
    local tween = TweenService:Create(part, tweenInfo, goal)
    return tween
end

return TweenUtils