local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)

local Scopes = require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "PlayerState", "Scopes"}))
local ScopesArray = Scopes.array.LocalSession
local ScopesSet = Scopes.enum.LocalSession

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
    registry:RegisterType("localSessionScopes", type_)
end