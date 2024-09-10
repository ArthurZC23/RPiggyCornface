local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local ViewportSticker = {}
ViewportSticker.__index = ViewportSticker
ViewportSticker.TAG_NAME = "ViewportSticker"

function ViewportSticker.new(inst)
    if not inst:FindFirstAncestorOfClass("Workspace") then return end
	local self = {}
    setmetatable(self, ViewportSticker)
    self._maid = Maid.new()
    local offsetLookV = inst.ViewportSticker.OffsetLook --LookVector
	local offsetV = inst.ViewportSticker.Offset
    local offsetAngle = inst:GetAttribute("VpsOffsetAngle") or Vector3.new(0, 0, 0)
	local lookV = inst.ViewportSticker.Look
    local setCFrameMethod = self:getSetCFrameMethod(inst)

	self._maid:Add(RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		local cameraCf = camera:GetRenderCFrame()
		local look = (cameraCf - cameraCf.Position)* lookV.Value
        inst:PivotTo(
            CFrame.lookAt(
                (cameraCf * CFrame.new(offsetLookV.Value)).Position,
			    cameraCf.Position + look)
                * CFrame.Angles(offsetAngle.X, offsetAngle.Y, offsetAngle.Z)
                + (cameraCf * CFrame.new(offsetV.Value).Position - cameraCf.Position)
            )
    end))

	return self
end

function ViewportSticker:getSetCFrameMethod(inst)
    if inst:IsA("Model") then
        return "SetPrimaryPartCFrame"
    elseif inst:IsA("BasePart") then
        return "CFrame"
    end
end

function ViewportSticker:Destroy()
    self._maid:Destroy()
end

return ViewportSticker