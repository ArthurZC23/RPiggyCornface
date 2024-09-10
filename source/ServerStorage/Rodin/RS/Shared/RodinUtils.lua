local module = {}

function module.transferMotorsProps(refMotors, targetMotors)
    for _, motor in pairs(targetMotors) do
        local refMotor = refMotors[motor.Name]
        if refMotor.Part0.Name == motor.Part0.Name and refMotor.Part1.Name == motor.Part1.Name then
            motor.C0 = refMotor.C0
            motor.C1 = refMotor.C1
            motor.Transform = refMotor.Transform
        end
    end
end

function module.transferMotorsPropsToModel(refMotors, targetModel)
    for _, motor in ipairs(targetModel:GetDescendants()) do
        if not motor:IsA("Motor6D") then continue end
        local refMotor = refMotors[motor.Name]
        if refMotor.Part0.Name == motor.Part0.Name and refMotor.Part1.Name == motor.Part1.Name then
            motor.C0 = refMotor.C0
            motor.C1 = refMotor.C1
            motor.Transform = refMotor.Transform
        end
    end
end

function module.transferPose(refModel, targetModel)
    local refMotors = module.getMotors(refModel)
    local targetMotors = module.getMotors(targetModel)
    return module.transferMotorsProps(refMotors, targetMotors)
end

function module.getMotors(model)
    local motors = {}
    for _, motor in ipairs(model:GetDescendants()) do
        if not motor:IsA("Motor6D") then continue end
        motors[motor.Name] = motor
    end
    return motors
end

function module.getNewSpeed(track, newDuration)
    local duration = track.Length
    if duration == 0 then
        warn("Track was not loaded. Using default value of 1 for track duration.")
        return 1
    end
    return (duration * 1) / newDuration
end

return module