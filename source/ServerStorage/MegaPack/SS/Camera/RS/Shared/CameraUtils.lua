local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local module = {}

function module.setMinZoom(min)
    localPlayer.CameraMinZoomDistance = min
end

function module.setMaxZoom(max)
    localPlayer.CameraMaxZoomDistance = max
end

function module.setUniqueZoom(zoom)
    localPlayer.CameraMinZoomDistance = zoom
    localPlayer.CameraMaxZoomDistance = zoom
end

function module.getCurrentZoom()
    -- https://devforum.roblox.com/t/how-to-get-camera-zoom/415066/4?u=bachatronic
    return (camera.CFrame.Position - camera.Focus.Position).Magnitude
end


return module