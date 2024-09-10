local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local ORIGIN = Vector3.new(0, 0, 0)

local Vpf = {}
Vpf.__index = Vpf
Vpf.TAG_NAME = "Vpf"

function Vpf.new(vpf)
	local self = {
        _maid = Maid.new(),
        vpf = vpf,
    }
	setmetatable(self, Vpf)
    if not self:getFields() then return end

	self.model:PivotTo(CFrame.new(ORIGIN, Vector3.new(0, 0, -1)))
	self.vpfCamera = self:createVpfCamera()

	self._maid:Add(self.cameraPositionV.Changed:Connect(function() self:updateCameraPosition() end))
	self._maid:Add(self.cameraAnglesV.Changed:Connect(function() self:updateCameraPosition() end))
	self._maid:Add(self.positionOffsetV.Changed:Connect(function() self:updateCameraPosition() end))

	self:updateCameraPosition()

	return self
end

function Vpf:updateCameraPosition()
	self.vpfCamera.CFrame =
		CFrame.new(self.cameraPositionV.Value, ORIGIN)
		* CFrame.Angles(self.cameraAnglesV.Value.X, self.cameraAnglesV.Value.Y, self.cameraAnglesV.Value.Z)
		+ self.positionOffsetV.Value
end

function Vpf:createVpfCamera()
	local camera = self._maid:Add(Instance.new("Camera"))
	self.vpf.CurrentCamera = camera
	camera.Parent = self.vpf
	return camera
end

function Vpf:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.model = self.vpf:FindFirstChild("Model") -- Model is not replicated instantly during replication
            if not self.model then return end

            self.cameraAnglesV = self.vpf:FindFirstChild("CameraAngles")
            if not self.cameraAnglesV then return end

            self.cameraPositionV = self.vpf:FindFirstChild("CameraPosition")
            if not self.cameraPositionV then return end

            self.positionOffsetV = self.vpf:FindFirstChild("CameraPositionOffset")
            if not self.positionOffsetV then return end

            if self.model.ClassName == "Model" then
                local pp = self.model.PrimaryPart
                if not pp then return end
            elseif self.model.ClassName == "Tool" then
                local pp = ComposedKey.getFirstDescendant(self.model, {"Handle"}) or ComposedKey.getFirstDescendant(self.model, {"Skeleton", "Handle"})
                if not pp then return end
            else
                error("Invalid root model.")
            end
            return true
        end,
        keepTrying=function()
            return self.vpf.Parent
        end,
        cooldown=nil
    })
end

function Vpf:Destroy()
	self._maid:Destroy()
end

return Vpf