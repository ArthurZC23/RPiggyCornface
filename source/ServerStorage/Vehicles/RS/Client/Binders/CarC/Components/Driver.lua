local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Chassis = Mod:find({"Vehicles", "Car", "Chassis"})

local Driver = {}
Driver.__index = Driver
Driver.className = "Driver"
Driver.TAG_NAME = Driver.className

function Driver.new(carObj)
    local self = {
        carObj = carObj,
        car = carObj.car,
        _maid = Maid.new(),
    }
    setmetatable(self, Driver)

    self.chassis = self._maid:Add(Chassis.new(self))
    self:setChassis()
    self:setGuis()
    self:setDriverInputLoop()

    return self
end

function Driver:setChassis()
    while true do -- Need to change
        -- get input
        -- calculate velocity
        -- update steer
        -- Update car state
        -- Update throttle
        -- take care of hand break
    end
end

function Driver:setChassis()
    self.chassis:InitializeDrivingValues()
    self.chassis:reset()
end

function Driver:setGuis()
    warn("Set guis")
end



function Driver:Destroy()
    self._maid:Destroy()
end

return Driver