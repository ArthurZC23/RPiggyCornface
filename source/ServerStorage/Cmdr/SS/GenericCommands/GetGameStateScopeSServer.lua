local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

return function (context, scope)
    local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
    local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

    local state = gameState:get("Session", scope)

	return TableUtils.print(state)
end