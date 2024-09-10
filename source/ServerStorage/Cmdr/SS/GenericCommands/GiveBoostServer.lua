local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Cronos = Mod:find({"Cronos", "Cronos"})

return function (context, player, boostId, duration)
    WaitFor.BObj(player, "PlayerState")

    :andThen(function(playerState)
        local action = {
            name = "addBoost",
            boostId = boostId,
            duration = duration,
            t0 = Cronos:getTime(),
        }
        playerState:set(S.Stores, "Boosts", action)
    end)

	return true
end