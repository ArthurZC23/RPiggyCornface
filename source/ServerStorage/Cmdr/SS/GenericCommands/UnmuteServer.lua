local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

return function (context, player)
    WaitFor.BObj(player, "PlayerChat"):timeout(10)
    :andThen(function(playerChat)
        playerChat:unmute()
    end)

	return true
end