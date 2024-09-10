local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

return function (context, player, keyName)
    local char = player.Character
    if not (char and char.Parent) then return end
    local keyId = Data.Puzzles.Keys.nameData[keyName].id
    WaitFor.BObj(char, "CharState")
    :andThen(function(charState)
        local action = {
            name = "addKey",
            id = keyId,
        }
        charState:set(S.Session, "MapPuzzles", action)
    end)

	return true
end