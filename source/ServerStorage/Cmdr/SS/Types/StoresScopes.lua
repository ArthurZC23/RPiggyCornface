local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Scopes = require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "PlayerState", "Scopes"}))
local ScopesArray = Scopes.array.Stores
local ScopesSet = Scopes.enum.Stores
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local type_ = {
    Autocomplete = function ()
        return ScopesArray
    end,
    Validate = function (scope)
        TableUtils.print(ScopesSet)
		return ScopesSet[scope]
	end,
	Parse = function (scope)
		return scope
	end,
}

return function (registry)
    registry:RegisterType("storesScopes", type_)
end