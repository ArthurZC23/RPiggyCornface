local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

return function (context, player, team)
    local char = player.Character
    if not (char and char.Parent) then return end
    player:SetAttribute("team", team)
    WaitFor.BObj(char, "CharHades"):andThen(function(charHades)
        charHades.KillSignalSE:Fire("ChangeTeam", {team = team})
    end)
end