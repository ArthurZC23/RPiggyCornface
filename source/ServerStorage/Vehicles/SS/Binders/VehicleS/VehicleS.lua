local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})

local vId = "1"

local VehicleS = {}
VehicleS.__index = VehicleS
VehicleS.className = "Vehicle"
VehicleS.TAG_NAME = VehicleS.className

VehicleS.vIdToVehicleComponent = {}

function VehicleS.new(vehicle)
    local self = {
        _maid = Maid.new(),
        vehicle = vehicle,
    }
    setmetatable(self, VehicleS)

    vehicle:SetAttribute("vId", vId)
    -- vehicleObj.vId = vId
    VehicleS.vIdToVehicleComponent[vId] = self
    self._maid:Add(function()
        VehicleS.vIdToVehicleComponent[vId] = nil
    end)

    vId = tostring(tonumber(vId) + 1)

    self:handleVehicleMass(vehicle)

    return self
end

function VehicleS:handleVehicleMass(vehicle)
    self._maid:Add(vehicle.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            self.mass += desc:GetMass()
        end
    end))
    self.mass = 0
    for _, desc in ipairs(vehicle:GetDescendants()) do
        if desc:IsA("BasePart") then
            self.mass += desc:GetMass()
        end
    end
end

function VehicleS:Destroy()
    self._maid:Destroy()
end

return VehicleS