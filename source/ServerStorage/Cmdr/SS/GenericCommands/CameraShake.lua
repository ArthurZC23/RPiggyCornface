local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local CameraShaker = Mod:find({"Camera", "CameraShaker", "CameraShaker"})
local CameraShakerPresets = Mod:find({"Camera", "CameraShaker", "Presets"})

local camera = workspace.CurrentCamera

return {
    Name = "CamShake",
	Aliases = {"cs"},
	Description = "Shake Camera.",
	Group = "DefaultAdmin",
	Args = {
        {
			Type = "cameraShakeAction",
			Name = "camShakeAction",
			Description = "CameraShake Action"
		},
		{
			Type = "cameraShakePreset",
			Name = "cameraShakePreset",
			Description = "CameraShake cameraShakePreset."
		},
	},
    ClientRun = function(context, camShakeAction, cameraShakePreset)
        local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
            camera.CFrame = camera.CFrame * shakeCf
        end)

        if camShakeAction == "Start" then
            camShake:Start()
            camShake:Shake(CameraShakerPresets[cameraShakePreset])
        -- elseif camShakeAction == "Stop" then
        --     camShake:Stop()
        -- elseif camShakeAction == "StopSustained" then
        --     camShake:StopSustained(1)
        -- else
        --     error(("camShakeAction %s is not valid"):format(camShakeAction))
        end

        return "Done"

	end
}