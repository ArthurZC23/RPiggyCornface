local module = {}

function module.setSpring(spring, stiffness, damping)
	spring.Stiffness = stiffness
	spring.Damping = damping
end

function module.setMotorsTorque(motors, torque)
	for _, motor in pairs(motors) do
		motor.MotorMaxTorque = torque
	end
end

function module.setWheelsFriction(wheels, friction)
	for _, wh in pairs(wheels) do
        local old = wh.CustomPhysicalProperties
        wh.CustomPhysicalProperties = PhysicalProperties.new(
            old.Density, friction, old.Elasticity, old.FrictionWeight, old.ElasticityWeight)
	end
end

function module.setMotorTorque(motors, torque)
	for _, motor in pairs(motors) do
		motor.MotorMaxTorque = torque
	end
end


function module.setMotorTorqueDamped(driverSeat, motors, torque, velocityDirection, accelDirection, maxSpeed, reverseSpeed)
	for _, motor in pairs(motors) do
		if maxSpeed == 0 then
			motor.MotorMaxTorque = 0
		else
			if accelDirection < 0 and velocityDirection < 0 then
				maxSpeed = reverseSpeed
			end
			local r = math.abs(driverSeat.AssemblyLinearVelocity.Magnitude / maxSpeed)
			motor.MotorMaxTorque = math.exp( -3 * r * r ) * torque
		end
	end
end

function module.setMotorMaxAcceleration(motors, acceleration)
	for _, motor in pairs(motors) do
		motor.MotorMaxAngularAcceleration = acceleration
	end
end

function module.setMotorsVelocity(motors, vel)
	for _, motor in pairs(motors) do
		motor.AngularVelocity = vel
	end
end

return module