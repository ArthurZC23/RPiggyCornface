local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)

local StateTypesServer = require(ComposedKey.getAsync(ReplicatedStorage, {"StateManager", "Shared", "PlayerState", "StateTypesServer"}))
local StateTypesServerArray = StateTypesServer.array
local StateTypesServerSet = StateTypesServer.enum


local type_ = {
    Autocomplete = function ()
        return StateTypesServerArray
    end,
    Validate = function (stateType)
		return rawget(StateTypesServerSet, stateType)
	end,
	Parse = function (stateType)
		return stateType
	end,
	Default = function()
		return StateTypesServerSet.Stores
	end,
}

return function (registry)
    registry:RegisterType("stateTypeServer", type_)
end