local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local CameraShakerPresets = Mod:find({"Camera", "CameraShaker", "Presets"})

local type_ = {
    Autocomplete = function ()
        local presets = TableUtils.getKeys(CameraShakerPresets._presets)
        return presets
    end,
    Validate = function (preset)
		return CameraShakerPresets._presets[preset]
	end,
	Parse = function (preset)
		return preset
	end,
}

return function (registry)
    registry:RegisterType("cameraShakePreset", type_)
end