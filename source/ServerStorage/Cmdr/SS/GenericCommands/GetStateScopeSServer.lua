local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

return function (context, player, stateType, scope)
	local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then return ("Player %s is not on this server"):format(player.Name) end

    local state = playerState:get(stateType, scope)

	return TableUtils.print(state)
end