local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

return function (context, player)
    local char = player.Character
    if not (char and char.Parent) then return end
    local DamageKillSE = SharedSherlock:find({"Bindable", "sync"}, {root = char, signal = "DamageKill"})
    if not DamageKillSE then return end
    DamageKillSE:Fire({deathCause="MonsterKill", cmdr = true})

	return true
end