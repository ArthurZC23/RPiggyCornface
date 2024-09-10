local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

return function (context, mapArea, id)
    local player = context.Executor
    local char = player.Character
    if not (char and char.Parent) then return end

    if mapArea == "Lobby" then
        local LobbySpawns = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace.Map, refName="LobbySpawns"})
        local _spawn = LobbySpawns.Model[id]
        char:PivotTo(_spawn.CFrame + 4 * Vector3.yAxis)
    else
        error(("Map area %s is not valid."):format(mapArea))
    end
	return true
end