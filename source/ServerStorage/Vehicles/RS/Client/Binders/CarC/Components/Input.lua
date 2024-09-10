local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Platform = Mod:find({"Platform"})
local Data = Mod:find({"Data", "Data"})

local LocalData = Mod:find({"Data", "LocalData"})
local Keymap = LocalData.Vehicles.Car.Keymap.Keymap

local Input = {}
Input.__index = Input
Input.className = "Input"
Input.TAG_NAME = Input.className

function Input.new(binderCar)
    local self = {
        binderCar = binderCar,
        _maid = Maid.new(),
    }
    setmetatable(self, Input)
    self._rawInput = self:createInputTable()
    self:bindActions()
    FastSpawn(self.inputLoop, self)

    return self
end

function Input:inputLoop()
    self:getInput()
    self.bindCar:updateChasis()
    self.bindCar:updateSteering()
    self.bindCar:updateThrottle()
    self.bindCar:updateHandbrake()
end

--Interpret input
function Input:getInput()
	if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
        self.bindCar:updatePhysics()
		---Let the control module handle all none-touch controls
		-- script.Throttle.Value = self:_calculateInput("Throttle") - self:_calculateInput("Brake")
		-- script.Steering.Value = self:_calculateInput("SteerLeft") + self:_calculateInput("SteerRight")
		-- script.HandBrake.Value = self:_calculateInput("Handbrake")

	else --The vehicle gui handles all the touch controls
        self.bindCar:updateGui()
		-- script.Throttle.Value = VehicleGui.throttleInput
		-- script.Steering.Value = VehicleGui.steeringInput
		-- script.HandBrake.Value = VehicleGui.handBrakeInput
	end
end


function Input:_updateRawInput(_, inputState, inputObj)
    local key = inputObj.KeyCode
    -- -- Not all of them have data
    -- local data = Keymap.getData(key)
    -- if not data then return end

    -- local axis = data.Axis
    -- return val
    self._rawInput[key] = Random.new():NextInteger(0, 1)
end

function Input:_calculateInput(action)
    local mappings = Keymap[action]
    local val = 0
    for _, data in ipairs(mappings) do
        local thisVal = self._rawInput[data.KeyCode]
        if math.abs(thisVal) > math.abs(val) then
			val = thisVal
		end
    end
    return val
end

function Input:createInputTable()
    local inputTable = self:resetInputTable({})
    self._maid:Add(function()
        self:resetInputTable()
    end)
    return inputTable
end

function Input:createInputTable()
    local inputTable = self:resetInputTable({})
    self._maid:Add(function()
        self:resetInputTable()
    end)
    return inputTable
end

function Input:resetInputTable(inputTable)
    for _, input in pairs(Keymap.actionToKey) do
       inputTable[input] = 0
    end
    return inputTable
end

function Input:Destroy()
    self._maid:Destroy()
end

return Input