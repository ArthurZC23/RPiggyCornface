local Data = script:FindFirstAncestor("Data")
local Speed = require(Data.Physics.Units.Speed)

local module = {}

-- Prototype
module["0"] = {
    MaxSpeed = 75 / Speed.mphToStudsps,
    ReverseSpeed = 45 / Speed.mphToStudsps,
    DrivingTorque = 3e4,
    BrakingTorque = 7e4,
    StrutSpringStiffnessFront = 28e3,
    StrutSpringDampingFront = 1430,
    StrutSpringStiffnessRear = 27e3,
    StrutSpringDampingRear = 1400,
    TorsionSpringStiffness = 20000,
    TorsionSpringDamping = 150,
    MaxSteer = 0.55,
    WheelFriction = 2,
    LimitSteerAtHighVel = true,
    SteerLimit = 0.2,
    requireGravityAdjust = true,
    InitialTorque = 1e4,
}

module["1"] = {
    MaxSpeed = 100 / Speed.mphToStudsps,
}


return module