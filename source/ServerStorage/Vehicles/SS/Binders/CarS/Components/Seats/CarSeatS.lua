local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local S = Data.Strings.Strings
local SeatsData = Data.Vehicles.Car.Seats.Seats

local CarSeatS = {}
CarSeatS.__index = CarSeatS
CarSeatS.className = "CarSeat"

function CarSeatS.new(seat, carObj)
    local self = {
        _maid = Maid.new(),
        carObj = carObj,
        seat = seat,
        charInTheSeat = nil,
    }
    setmetatable(self, CarSeatS)

    self:createRemotes()
    self:handleRemotes()

    return self
end

function CarSeatS:handleRemotes()
    -- Handle vehicle removal from workspace
    self._maid:Add(function()
        if self.seatMaid and self.seatMaid.Destroy then self.seatMaid:Destroy() end
    end)

    -- Character request
    self.ExitVehicleRE.OnServerEvent:Connect(function(player)
        if player ~= self.charInTheSeat then return end
        if self.seatMaid and self.seatMaid.Destroy then self.seatMaid:Destroy() end
    end)

    self.EnterVehicleRE.OnServerEvent:Connect(function(player)
        local VehicleSeatsData = SeatsData.idToData[self.carObj.carMId] or SeatsData.idToData["0"]
        local seatData = VehicleSeatsData[self.seat:GetAttribute("SeatId")]

        if not self:canPlayerUseSeat(player, seatData) then return end

        -- This allows to npc to join as well
        self.charInTheSeat = player.Character

        self.seatMaid = Maid.new()

        -- What if char is destroyed or player leaves the game? Only need to deal with char removal
        -- Could use theCharacter signal
        self.seatMaid:Add(self.charInTheSeat.AncestryChanged:Connect(function(_, parent)
            if not parent then self.seatMaid:Destroy() end
        end))

        self.seatMaid:Add(function()
            self.charInTheSeat = nil
            self.seatMaid = nil
        end)
        if not self:sitPlayerOnVehicle(player) then
            self.seatMaid:Destroy()
            return
        end
    end)
end

function CarSeatS:sitPlayerOnVehicle(player)
    local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end

    self.seatMaid:Add(playerState:getEvent(S.Session, "Vehicle", "exitVehicle"):Connect(function()
        self.seatMaid:Destroy()
    end))

    local instNameToData = SeatsData.instNameToData[self.carObj.carMId] or SeatsData.instNameToData["0"]
    local seatData = instNameToData[self.seat.Name]
    local action = {
        name="enterVehicle",
        seatId=seatData.seatId,
        vId=self.carObj.vId,
    }
    playerState:set(S.Session, "Vehicle", action)
    return true
end

function CarSeatS:canPlayerUseSeat(player, seatData)
    if self.charInTheSeat then return end

    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    if humanoid.Sit then return end

    return true
end

function CarSeatS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.seat, {
        events = {
            "EnterVehicle",
            "ExitVehicle",
            "ForceExitVehicle",
        },
        functions = {},
    }))
end

function CarSeatS:Destroy()
    self._maid:Destroy()
end

return CarSeatS