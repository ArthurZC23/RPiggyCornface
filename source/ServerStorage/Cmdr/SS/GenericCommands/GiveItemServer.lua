local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

return function (context, player, itemName)
    local itemId = Data.Items.Items.nameData[itemName].id
    WaitFor.BObj(player, "PlayerState")
    :andThen(function(playerState)
        local action = {
            name = "add",
            id = itemId,
        }
        playerState:set(S.Session, "Items", action)
    end)

	return true
end