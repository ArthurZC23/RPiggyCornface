-- Need to guarantee that you get all constraints in the client

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local module = {}

function module.getVehicleMotors(constraints, numMotors)
    return SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local motors = {}
            for _, c in pairs(constraints:GetChildren()) do
                if c:IsA("CylindricalConstraint") then
                    table.insert(motors, c)
                end
            end
            if #motors ~= numMotors then return end
            return motors
        end,
        keepTrying=function()
            return true -- Change this
        end,
    })
end

function module.getSprings(constraints, springType)
    local springs = {}
    local function search(children)
		local searchStrutSpring = "StrutSpring"
		local searchFrontSpring = "StrutSpringF"
		local searchTorsionSpring = "TorsionBarSpring"
		for _, c in pairs(children) do
			if c:IsA("SpringConstraint") then
				if springType == "StrutFront" then
					if string.find(c.Name, searchFrontSpring) then
						table.insert(springs, c)
					end
				elseif springType == "StrutRear" then
					if (not string.find(c.Name, searchFrontSpring)) and string.find(c.Name, searchStrutSpring) then
						table.insert(springs, c) -- we have option of Mid and Rear for these
					end
				elseif springType == "TorsionBar" then
					if string.find(c.Name, searchTorsionSpring) then
						table.insert(springs, c)
					end
				end
			end
		end
	end

	search(constraints:GetChildren())
	return springs
end

function module.getMotorVelocity(motor)
	return motor.Attachment1.WorldAxis:Dot( motor.Attachment1.Parent.RotVelocity )
end

function module.GetAverageVelocity(motors)
	local t = 0
	for _, motor in pairs(motors) do
		t = t + module.getMotorVelocity(motor)
	end
	return t * (1/#motors)
end

function module.getWheels(chassisModel, numWheels)

    return SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local wheels = {}
            for _, model in ipairs(chassisModel:GetChildren()) do
                if not model:IsA("Model") then continue end
                local wh = model:FindFirstChild("Wheel")
                if not wh then continue end
                table.insert(wheels, wh)
            end
            if #wheels ~= numWheels then return end
            return wheels
        end,
        keepTrying=function()
            return chassisModel.Parent
        end,
    })
end

return module