local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

return function (context, player, value)
    WaitFor.BObj(player, "PlayerState")
    :andThen(function(playerState)
        local action = {
            name = "increment",
            scoreType = S.Kills,
            timeType = "allTime",
            value = value,
        }
        playerState:set(S.Stores, "Scores", action)
    end)

	return true
end