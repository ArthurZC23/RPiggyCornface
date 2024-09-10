local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local CameraMan = {}
CameraMan.__index = CameraMan

function CameraMan.new()
    local self = {
        _maid = Maid.new()
    }
	setmetatable(self, CameraMan)
    return self
end

function CameraMan:tween(tweenInfo, goal)
	local tween  = TweenService:Create(camera, tweenInfo, goal)
	self._maid:Add(function()
		tween:Pause()
		tween:Destroy()
	end)
    tween:Play()
end

function CameraMan:performTrajectory(trajectory, time_, kwargs)
	local t = 0
	self._maid:Add(function()
		t = time_ + 1e-2
	end)
    while t <= time_ do
		local step = RunService.Heartbeat:Wait()
        trajectory(camera, t, step, kwargs)
        t = t + step
    end
end

function CameraMan:adjustZoom(minZoomDistance, maxZoomDistance)
	localPlayer.CameraMinZoomDistance = minZoomDistance
	localPlayer.CameraMaxZoomDistance = maxZoomDistance
end

function CameraMan:focus(focusPoint, offset, pureOffset)
	pureOffset = pureOffset or Vector3.new(0, 0, 0)
	camera.CFrame =
        CFrame.new(
            focusPoint.Position + offset,
            focusPoint.Position
	    ) + pureOffset
end

function CameraMan:PutCameraOnLocalPlayer()
	camera.CameraType = Enum.CameraType.Custom
	local char = localPlayer.Character
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end

function CameraMan:Destroy()
	self._maid:Destroy()
end

return CameraMan