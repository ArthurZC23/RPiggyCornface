local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})
local Athena = Mod:find({"Athena", "Athena"})

local TweenGroup = {}
TweenGroup.__index = TweenGroup

function TweenGroup.new(tweens)
    local self = {
        tweens = tweens or {},
    }
    setmetatable(self, TweenGroup)
    return self
end

function TweenGroup:addTweens(tweens)
    TableUtils.concatArrays(self.tweens, tweens)
end

function TweenGroup:Play()
    for _, tween in ipairs(self.tweens) do
        tween:Play()
    end
end

function TweenGroup:Pause()
    for _, tween in ipairs(self.tweens) do
        tween:Pause()
    end
end

function TweenGroup:Cancel()
    for _, tween in ipairs(self.tweens) do
        tween:Cancel()
    end
end

function TweenGroup:AllCompletedOnce()
    local promises = {}
    for _, tween in ipairs(self.tweens) do
        table.insert(promises, Promise.fromEvent(tween.Completed))
    end
    return Promise.all(promises)
end

function TweenGroup:AnyCompletedOnce()
    local promises = {}
    for _, tween in ipairs(self.tweens) do
        table.insert(promises, Promise.fromEvent(tween.Completed))
    end
    return Promise.any(promises)
end

function TweenGroup:Destroy()
    for _, tween in ipairs(self.tweens) do
        tween:Destroy()
    end
end

return TweenGroup