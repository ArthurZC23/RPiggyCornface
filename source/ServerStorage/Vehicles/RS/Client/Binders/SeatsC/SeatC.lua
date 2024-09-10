local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})

local Seats = script:FindFirstAncestor("SeatsC")
local PromptGui = require(ComposedKey.getAsync(Seats, {"Interface", "PromptGui"}))

local localPlayer = Players.LocalPlayer

local Seat = {}
Seat.__index = Seat
Seat.className = "DriverSeat"

function Seat.new(seat, carObj)
    local self = {
        carObj = carObj,
        seat = seat,
        _maid = Maid.new(),
    }
    setmetatable(self, Seat)

    if not self:addComponents() then return end

    return self
end

function Seat:addComponents()
    self.promptGui = PromptGui.new(self.carObj, self.seat)
    if not self.promptGui then return end
    self._maid:Add(self.promptGui)
    return true
end

function Seat:Destroy()
    self._maid:Destroy()
end

return Seat