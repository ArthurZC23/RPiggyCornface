local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local profileBegin = debug.profilebegin
local profileEnd = debug.profileend
local profileTag = "CameraShakerUpdate"

local V3 = Vector3.new
local CF = CFrame.new
local ANG = CFrame.Angles
local RAD = math.rad
local v3Zero = V3()

local RootF = script:FindFirstAncestor("CameraShaker")
local CameraShakeInstance = require(RootF:WaitForChild("CameraShakeInstance"))
local CameraShakeState = CameraShakeInstance.CameraShakeState

local defaultPosInfluence = V3(0.15, 0.15, 0.15)
local defaultRotInfluence = V3(1, 1, 1)

local CameraShaker = {}
CameraShaker.__index = CameraShaker
CameraShaker.className = "CameraShaker"

CameraShaker.CameraShakeInstance = CameraShakeInstance
CameraShaker.Presets = require(RootF:WaitForChild("CameraShakePresets"))

function CameraShaker.new(renderPriority, callback)
    assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
	assert(type(callback) == "function", "Callback must be a function")

    local self = {
        _running = false,
		_renderName = "CameraShaker",
		_renderPriority = renderPriority,
		_posAddShake = v3Zero,
		_rotAddShake = v3Zero,
		_camShakeInstances = {},
		_removeInstances = {},
		_callback = callback,
        _maid = Maid.new(),
    }
    setmetatable(self, CameraShaker)

    self._maid:Add(function()
        self:Stop()
    end)

    return self
end

function CameraShaker:Start()
	if (self._running) then return end
	self._running = true

	RunService:BindToRenderStep(self._renderName, self._renderPriority, function(dt)
		profileBegin(profileTag)
		local cf = self:Update(dt)
		profileEnd()
		self._callback(cf)
	end)
end

function CameraShaker:Stop()
	if (not self._running) then return end
	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function CameraShaker:StopSustained(duration)
	for _,c in pairs(self._camShakeInstances) do
		if (c.fadeOutDuration == 0) then
			c:StartFadeOut(duration or c.fadeInDuration)
		end
	end
end

function CameraShaker:Update(dt)
	local posAddShake = v3Zero
	local rotAddShake = v3Zero

	local instances = self._camShakeInstances

	-- Update all instances:
	for i = 1,#instances do

		local c = instances[i]
		local state = c:GetState()

		if (state == CameraShakeState.Inactive and c.DeleteOnInactive) then
			self._removeInstances[#self._removeInstances + 1] = i
		elseif (state ~= CameraShakeState.Inactive) then
			local shake = c:UpdateShake(dt)
			posAddShake = posAddShake + (shake * c.PositionInfluence)
			rotAddShake = rotAddShake + (shake * c.RotationInfluence)
		end
		
	end
	
	-- Remove dead instances:
	for i = #self._removeInstances,1,-1 do
		local instIndex = self._removeInstances[i]
		table.remove(instances, instIndex)
		self._removeInstances[i] = nil
	end
	
	return CF(posAddShake) *
			ANG(0, RAD(rotAddShake.Y), 0) *
			ANG(RAD(rotAddShake.X), 0, RAD(rotAddShake.Z))
	
end


function CameraShaker:Shake(shakeInstance)
	assert(type(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	return shakeInstance
end


function CameraShaker:ShakeSustain(shakeInstance)
	assert(type(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	shakeInstance:StartFadeIn(shakeInstance.fadeInDuration)
	return shakeInstance
end


function CameraShaker:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
	local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
	shakeInstance.PositionInfluence = (typeof(posInfluence) == "Vector3" and posInfluence or defaultPosInfluence)
	shakeInstance.RotationInfluence = (typeof(rotInfluence) == "Vector3" and rotInfluence or defaultRotInfluence)
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	return shakeInstance
end


function CameraShaker:StartShake(magnitude, roughness, fadeInTime, posInfluence, rotInfluence)
	local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime)
	shakeInstance.PositionInfluence = (typeof(posInfluence) == "Vector3" and posInfluence or defaultPosInfluence)
	shakeInstance.RotationInfluence = (typeof(rotInfluence) == "Vector3" and rotInfluence or defaultRotInfluence)
	shakeInstance:StartFadeIn(fadeInTime)
	self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
	return shakeInstance
end

function CameraShaker:Destroy()
    self._maid:Destroy()
end

return CameraShaker