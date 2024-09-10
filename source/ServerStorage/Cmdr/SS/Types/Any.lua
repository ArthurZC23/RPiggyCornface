local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local methods = {
    "Start",
    "Stop",
    "StopSustained",
}

local type_ = {
    Validate = function (method)
		return true
	end,
	Parse = function (method)
		return method
	end,
}

return function (registry)
    registry:RegisterType("any", type_)
end