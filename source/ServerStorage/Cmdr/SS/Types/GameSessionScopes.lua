local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)

local Scopes = require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "GameState", "Scopes"}))
local ScopesArray = Scopes.array.Session
local ScopesSet = Scopes.enum.Session

local type_ = {
    Autocomplete = function ()
        return ScopesArray
    end,
    Validate = function (scope)
		return ScopesSet[scope]
	end,
	Parse = function (scope)
		return scope
	end,
}

return function (registry)
    registry:RegisterType("gameSessionScopes", type_)
end