local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local gui = PlayerGui:WaitForChild("Fade")

local fadeMask = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="FadeMask"})
local hBorders = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="HBorders"})
local vBorders = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="VBorders"})

local MIN_SIZE = 0.1
local MAX_SIZE = 4
local STEP = 0.12

local camera = workspace.CurrentCamera

local module = {}

function module.beforeTeleport()
    fadeMask.Size = UDim2.fromScale(MAX_SIZE, MAX_SIZE)
    while fadeMask.Size.X.Scale > MIN_SIZE do
		RunService.Heartbeat:Wait()
		fadeMask.Size = UDim2.fromScale(fadeMask.Size.X.Scale - STEP, fadeMask.Size.Y.Scale - STEP)
		for _, frame in ipairs(hBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			frame.Size = UDim2.fromScale((1 - fadeMask.Size.X.Scale)/2, 1)
		end
		for _, frame in ipairs(vBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			if frame.Name == "BorderT" then
				frame.Size = UDim2.fromScale(1, 0.1 + (1 - fadeMask.Size.Y.Scale)/2)
			else
				frame.Size = UDim2.fromScale(1, (1 - fadeMask.Size.Y.Scale)/2)
			end
		end
    end
end

function module.afterTeleport(charTeleport, kwargs)
    local hrp = charTeleport.charParts.hrp
    local cf = hrp.CFrame
    local pos = cf.Position - 8 * cf.LookVector + 10 * cf.UpVector + 8 * cf.RightVector
    camera.CFrame = CFrame.lookAt(pos, hrp.Position)

    while fadeMask.Size.X.Scale < MAX_SIZE do
		RunService.Heartbeat:Wait()
		fadeMask.Size = UDim2.fromScale(fadeMask.Size.X.Scale + STEP, fadeMask.Size.Y.Scale + STEP)
		for _, frame in ipairs(hBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			frame.Size = UDim2.fromScale(math.max((1 - fadeMask.Size.X.Scale)/2, 0), 1)
		end
		for _, frame in ipairs(vBorders:GetChildren()) do
            if not frame:IsA("Frame") then continue end
			if frame.Name == "BorderT" then
				frame.Size = UDim2.fromScale(1, math.max(0.1 + (1 - fadeMask.Size.Y.Scale)/2, 0.1))
			else
				frame.Size = UDim2.fromScale(1, math.max((1 - fadeMask.Size.Y.Scale)/2, 0))
			end
		end
	end
end

return module