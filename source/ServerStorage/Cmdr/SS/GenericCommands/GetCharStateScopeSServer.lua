local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

return function (context, player, stateType, scope)
	local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharState"})
    local char = player.Character
    if not char then return ("Char %s is not on the workspace"):format(char.Name) end
    local charState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=char})
    if not charState then return ("CharState %s was not found"):format(char.Name) end

    local state = charState:get(stateType, scope)

	return TableUtils.print(state)
end