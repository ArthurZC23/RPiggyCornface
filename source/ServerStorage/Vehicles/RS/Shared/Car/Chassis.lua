local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local PhisicsConstants = Data.Physics.Constants
local ChassisData = Data.Vehicles.Car.Chassis.Chassis
local ChassisReplicationData = Data.Vehicles.Car.Chassis.Replication

local Shared = script:FindFirstAncestor("Shared")
local Getters = require(Shared:WaitForChild("Getters"))
local Setters = require(Shared:WaitForChild("Setters"))

local Chassis = {}
Chassis.__index = Chassis
Chassis.className = "Chassis"
Chassis.TAG_NAME = Chassis.className

function Chassis.new(carObj)
    local car = carObj.car
    local self = {
        carMId = carObj.carMId,
        car = car,
        constraints = car:WaitForChild("Chassis"):WaitForChild("Constraints"),
        root = car:WaitForChild("Chassis"),
        driverSeat = car:WaitForChild("Seats"):WaitForChild("DriverSeatFL"),
        targetAttachment = car:WaitForChild("Chassis"):WaitForChild("RedressMount"):WaitForChild("RedressTarget"),
        -- Constraint tables always ordered FL, FR, RL, RR
        LimitSteerAtHighVel = true,
        SteerLimit = 0.2,
        redressMount = car:WaitForChild("Chassis"):WaitForChild("RedressMount"),
        redressingDb = false,
        _maid = Maid.new(),
    }
    setmetatable(self, Chassis)

    self.chassisData, self.replicationData = self:getChassisData()
    self:adjustParamsToGravity()


    return self
end

function Chassis:getChassisData()
    local chassisData = ChassisData[self.carMId] or {}
    local protoData = ChassisData["0"]
    for key in pairs(protoData) do
        chassisData[key] = chassisData[key] or protoData[key]
    end

    local chassisReplicationData = ChassisReplicationData[self.carMId] or {}
    local protoReplicationData = ChassisReplicationData["0"]
    for key in pairs(protoReplicationData) do
        chassisReplicationData[key] = chassisReplicationData[key] or protoReplicationData[key]
    end
    return chassisData, chassisReplicationData
end

function Chassis:Initialize()

    self.motors = Getters.getVehicleMotors(self.constraints, self.replicationData.NumMotors)
    self.wheels = Getters.getWheels(self.root, self.replicationData.NumWheels)
	local strutSpringsFront = Getters.getSprings(self.constraints, "StrutFront")
	local strutSpringsRear = Getters.getSprings(self.constraints, "StrutRear")
	local torsionSprings = Getters.getSprings(self.constraints, "TorsionBar")

    self.SteeringPrismatic = self.constraints:WaitForChild("SteeringPrismatic")
	self.SteeringPrismatic.UpperLimit = self.chassisData["MaxSteer"]
	self.SteeringPrismatic.LowerLimit = -self.chassisData["MaxSteer"]

	for _, spring in pairs(strutSpringsFront) do
        Setters.setSpring(
            spring,
            self.strutSpringStiffnessFront,
            self.strutSpringDampingFront
        )
	end
	for _, spring in pairs(strutSpringsRear) do
        Setters.setSpring(
            spring,
            self.strutSpringStiffnessRear,
            self.strutSpringDampingRear
        )
	end
	for _, spring in pairs(torsionSprings) do
        Setters.setSpring(
            spring,
            self.torsionSpringStiffness,
            self.torsionSpringDamping
        )
	end

    Setters.setWheelsFriction(self.wheels, self.chassisData["WheelFriction"])
	Setters.setMotorsTorque(self.motors, self.chassisData["InitialTorque"])
end

function Chassis:updateSteering(steer, currentVel)
	if self.LimitSteerAtHighVel then
		local c = self.SteerLimit * (math.abs(currentVel)/self.chassisData["MaxSpeed"]) + 1
		--decrease steer value as speed increases to prevent tipping (handbrake cancels this)
		steer = steer/c
	end
	self.SteeringPrismatic.TargetPosition = steer * steer * steer * self.chassisData["MaxSteer"]
end

function Chassis:updateThrottle(throttle, currentSpeed)
	local targetVel = 0

	if math.abs(throttle) < 0.1 then
		-- Idling
        print("Idle")
		Setters.setMotorMaxAcceleration(self.motors, math.huge)
        Setters.setMotorTorque(self.motors, 2000)
	elseif math.sign(throttle * currentSpeed) > 0 or math.abs(currentSpeed) < 0.5 then
		Setters.setMotorMaxAcceleration(self.motors, math.huge)

        local velocity = self.driverSeat.AssemblyLinearVelocity
		local velocityHat = velocity.Unit
		local directionalVector = self.driverSeat.CFrame.lookVector
		local dotProd = velocityHat:Dot(directionalVector) -- Dot product is a measure of how similar two vectors are; if they're facing the same direction, it is 1, if they are facing opposite directions, it is -1, if perpendicular, it is 0

		Setters.setMotorTorqueDamped(
            self.driverSeat,
            self.motors,
            self.drivingTorque * throttle * throttle,
            dotProd,
            math.sign(throttle),
            self.chassisData["MaxSpeed"],
            self.chassisData["ReverseSpeed"]
        )
		-- Arbitrary large number
		local movingBackwards = dotProd < 0
		local acceleratingBackwards = throttle < 0
		local useReverse = (movingBackwards and acceleratingBackwards)

		local maxSpeed = (useReverse and self.chassisData["ReverseSpeed"] or self.chassisData["MaxSpeed"])
		targetVel = math.sign(throttle) * maxSpeed
	else
		-- Braking
		Setters.setMotorMaxAcceleration(self.motors, 100)
		Setters.setMotorTorque(self.motors, self.brakingTorque * throttle * throttle)
		targetVel = math.sign(throttle) * 500
	end

	Setters.setMotorsVelocity(self.motors, targetVel)
end

function Chassis:Redress()
    if self.redressingDb then return end
    self.redressingDb = true

    local p = self.driverSeat.CFrame.Position + Vector3.new(0, 10, 0)
    local xc = self.driverSeat.CFrame.RightVector
    xc = Vector3.new(xc.X, 0, xc.Z).Unit

    local yc = Vector3.new(0, 1, 0)

    self.targetAttachment.Parent = workspace.Terrain
    self.targetAttachment.Position = p
    self.Axis = xc
    self.SecondaryAxis = yc
    self.redressMount.RedressOrientation.Enabled = true
    self.redressMount.RedressPosition.Enabled = true
    Cronos.wait(1.5)
    self.redressMount.RedressOrientation.Enabled = false
    self.redressMount.RedressPosition.Enabled = false
    self.targetAttachment.Parent = self.redressMount
    Cronos.wait(2)

    self.redressingDb = false
end

function Chassis:reset()
    -- This should be in a maid
    self:updateThrottle(1, 1)
    self:updateSteering(1, 0)
    self:enableHandbrake()
    Setters.setMotorTorque(self.motors, self.brakingTorque)
    Setters.setMotorsVelocity(self.motors, 0)
    Setters.updateSteering(0, 0)
    self.redressMount.RedressOrientation.Enabled = true
    self.redressMount.RedressPosition.Enabled = true
    self.redressMount.RedressOrientation.Enabled = false
    self.redressMount.RedressPosition.Enabled = false

    self.redressingDb = false -- Why?
end

function Chassis:enableHandbrake()
    Setters.setMotorMaxAcceleration(self.motors, math.huge)
    for i=3,4 do
        self.motors[i].MotorMaxTorque = self.brakingTorque
        self.motors[i].AngularVelocity = 0
    end
end

    -- Need to adjust gravity everytime maxVelocity changes
function Chassis:adjustParamsToGravity()
    local gravityChange = workspace.Gravity / PhisicsConstants.gravity.default

    self.drivingTorque = self.chassisData.DrivingTorque * gravityChange
    self.brakingTorque = self.chassisData.BrakingTorque * gravityChange

    self.strutSpringStiffnessFront = self.chassisData.StrutSpringStiffnessFront * gravityChange
    self.strutSpringDampingFront = self.chassisData.StrutSpringDampingFront * math.sqrt(gravityChange)
    self.strutSpringStiffnessRear = self.chassisData.StrutSpringStiffnessRear * gravityChange
    self.strutSpringDampingRear = self.chassisData.StrutSpringDampingRear * math.sqrt(gravityChange)

    self.torsionSpringStiffness = self.chassisData.TorsionSpringStiffness * gravityChange
    self.torsionSpringDamping = self.chassisData.TorsionSpringDamping * math.sqrt( gravityChange )
end

--Get average angular velocity from all 4 wheels
function Chassis:getAverageVelocity()
	local omega = 0
	for _, motor in ipairs(self.motors) do
		omega += Getters.getMotorVelocity(motor)
	end
	return omega/(#self.motors)
end

function Chassis:handleHandbreak()

end

function Chassis:enableHandbreak()
    warn("Implement Hand break.")
end

function Chassis:update()
    local avgVelocity = self:getAverageVelocity()
    local steer = self.car:GetAttribute("Steering")
    self:updateSteering(steer, avgVelocity)
    local throttle = self.car:GetAttribute("Throttle")
    --print("Throttle", throttle)
    self:updateThrottle(throttle, avgVelocity)
    local handBrake = self.car:GetAttribute("HandBrake")
    if handBrake > 0 then
        self:enableHandbreak()
    end
end

function Chassis:Destroy()
    self._maid:Destroy()
end

return Chassis