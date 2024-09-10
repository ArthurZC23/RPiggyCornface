local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local TryDeveloperPurchaseBE = ServerStorage.Bindables.Events:WaitForChild("TryDeveloperPurchase")

return function (context, player, value)
    local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = player})
    if not playerState then return end
    do
        local action = {
            name = "set",
            scoreType = S.FinishChapter,
            timeType = "allTime",
            value = value,
        }
        playerState:set(S.Stores, "Scores", action)
    end

	return true
end