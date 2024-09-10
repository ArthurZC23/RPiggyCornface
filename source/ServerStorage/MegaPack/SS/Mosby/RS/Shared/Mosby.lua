local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TweenGroup = Mod:find({"Tween", "TweenGroup"})
local TweenFactory = Mod:find({"Tween", "TweenFactory"})
local TableUtils = Mod:find({"Table", "Utils"})

local module = {}

function module.scaleModel(model, scale)
    local modelPivot = model:GetPivot()
    -- local pp = model.PrimaryPart
    -- assert(pp, "Model requires Primary Part.")

    for i, desc in ipairs(model:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.Size = desc.Size * Vector3.new(
            scale[desc:GetAttribute("MosbyAxisChangeX") or "X"],
            scale[desc:GetAttribute("MosbyAxisChangeY") or "Y"],
            scale[desc:GetAttribute("MosbyAxisChangeZ") or "Z"]
        )
        local deltaR = (desc.Position - modelPivot.Position)
        local rotation = desc.CFrame.Rotation
        desc.CFrame = CFrame.new(modelPivot.Position + deltaR * scale) * rotation
    end
end

function module.resizeModel(model, newSize, normalizationSize)
    if not normalizationSize then
        local _, bbSize = model:GetBoundingBox()
        normalizationSize = bbSize
    end
    local scale = newSize / normalizationSize
    module.scaleModel(model, scale)
end

function module.tweenModelScale(model, tweenInfo, scale, kwargs)
    -- local pp = model.PrimaryPart
    -- assert(pp, "Model requires Primary Part.")
    kwargs = kwargs or {}
    local modelPivot = model:GetPivot()

    local tweens = TweenFactory.createDescendantsTweens(
        model,
        tweenInfo,
        function(desc)
            local deltaR = (desc.Position - modelPivot.Position)
            local rotation = desc.CFrame.Rotation
            local goal = {
                CFrame = CFrame.new(modelPivot.Position + deltaR * scale) * rotation,
                Size = desc.Size * scale,
            }
            if kwargs.extraGoals then
                TableUtils.complementRestrained(goal, kwargs.extraGoals())
            end
            return goal
        end,
        function(desc)
            if not desc:IsA("BasePart") then return false end
            return true
        end
    )
    local tweenGroup = TweenGroup.new(tweens)
    return tweenGroup
end

return module