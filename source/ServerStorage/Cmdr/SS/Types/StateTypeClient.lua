local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))

local StateTypes = require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "PlayerState", "StateTypesClient"}))
local StateTypesArray = StateTypes.array
local StateTypesSet = StateTypes.enum

local type_ = {
    Autocomplete = function ()
        return StateTypesArray
    end,
    Validate = function (stateType)
		return StateTypesSet[stateType]
	end,
	Parse = function (stateType)
		return stateType
	end,
	Default = function()
		return StateTypes.LocalSession
	end,
}

return function (registry)
    registry:RegisterType("stateTypeClient", type_)
end