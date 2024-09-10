local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local VehicleSeatS = {}
VehicleSeatS.__index = VehicleSeatS
VehicleSeatS.className = "VehicleSeat"
VehicleSeatS.TAG_NAME = VehicleSeatS.className

function VehicleSeatS.new(seat)
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, VehicleSeatS)

    self.vehicle = self:getVehicle(seat)
    self:handlePlayerRequest()

    return self
end

function VehicleSeatS:getVehicle(seat)
    local binderVehicle = SharedSherlock:find({"Binders", "getBinder"}, {tag="Vehicle"})
    local vehicleObj = BinderUtils.findFirstAncestor()
    -- Find vehicle tag.
    -- Fire signal in vehicle tag.
    -- Abstract Vehicle class forwards the signal to the concrete implementation.
end

function VehicleSeatS:handlePlayerRequest()

end

function VehicleSeatS:Destroy()
    self._maid:Destroy()
end

return VehicleSeatS