local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local TableUtils = Mod:find({"Table", "Utils"})
local Data = Mod:find({"Data", "Data"})
local SeatsData = Data.Vehicles.Car.Seats.Seats

local RootF = script:FindFirstAncestor("SeatsC")
local Seat = require(ComposedKey.getAsync(RootF, {"SeatC"}))

local SeatsC = {}
SeatsC.__index = SeatsC
SeatsC.className = "Seats"
SeatsC.TAG_NAME = SeatsC.className

function SeatsC.new(carObj)
    local self = {
        carObj = carObj,
        _maid = Maid.new(),
    }
    setmetatable(self, SeatsC)

    if not self:getFields() then return end
    if not self:addSeatComponents() then return end

    return self
end

function SeatsC:getFields()
    return SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.seatsData = SeatsData.idToData[self.carObj.carMId] or SeatsData.idToData["0"]
            local SeatsM = self.carObj.car:FindFirstChild("SeatsC")
            if not SeatsM then return end
            self.seats = SeatsM:GetChildren()
            if #self.seats ~= TableUtils.len(self.seatsData) then return end
            return true
        end,
        keepTrying=function()
            return self.carObj.car.Parent
        end,
    })
end

function SeatsC:addSeatComponents()
    for _, seat in ipairs(self.seats) do
        local seatObj = Seat.new(seat, self.carObj)
        if not seatObj then return end
        self._maid:Add(seatObj)
    end

    return true
end

function SeatsC:Destroy()
    self._maid:Destroy()
end

return SeatsC