local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})
local Athena = Mod:find({"Athena", "Athena"})

local TweenFactory = {}
TweenFactory.__index = TweenFactory

function TweenFactory.createArrayTweens(array, tweenInfo, goals, validation)
    local tweens = {}
    for _, desc in ipairs(array) do
        if validation and not validation(desc) then continue end
        local _tweenInfo
        if typeof(tweenInfo) == "function" then
            _tweenInfo = tweenInfo(desc)
        else
            _tweenInfo = tweenInfo
        end
        local _goals
        if typeof(goals) == "function" then
            _goals = goals(desc)
        else
            _goals = goals
        end
        local tween = TweenService:Create(desc, _tweenInfo, _goals)
        table.insert(tweens, tween)
    end
    return tweens
end

function TweenFactory.createDescendantsTweens(model, tweenInfo, goals, validation)
    local tweens = {}
    for _, desc in ipairs(model:getDescendants()) do
        if not validation(desc) then continue end
        local _tweenInfo
        if typeof(tweenInfo) == "function" then
            _tweenInfo = tweenInfo(desc)
        else
            _tweenInfo = tweenInfo
        end
        local _goals
        if typeof(goals) == "function" then
            _goals = goals(desc)
        else
            _goals = goals
        end
        local tween = TweenService:Create(desc, _tweenInfo, _goals)
        table.insert(tweens, tween)
    end
    return tweens
end

return TweenFactory