local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})

local CarDriverSeatS = {}
CarDriverSeatS.__index = CarDriverSeatS
CarDriverSeatS.className = "CarDriverSeatS"
CarDriverSeatS.TAG_NAME = CarDriverSeatS.className

function CarDriverSeatS.new(carObj, seat, player)
    local self = {
        carObj = carObj,
        _maid = Maid.new(),
        player=player,
        seat = seat,
    }
    self.attributes = self:getAttributes()
    setmetatable(self, CarDriverSeatS)

    self:putPlayerInTheSeat()

    return self
end

function CarDriverSeatS:getAttributes()
    self.carObj.car:SetAttribute("Throttle", 0)
    self.carObj.car:SetAttribute("Steering", 0)
    self.carObj.car:SetAttribute("HandBrake", 0)
    self.attributes = {
        Throttle = self.carObj.car:GetAttribute("Throttle"),
        Steering = self.carObj.car:GetAttribute("Steering"),
        HandBrake = self.carObj.car:GetAttribute("HandBrake"),
    }
end

function CarDriverSeatS:putPlayerInTheSeat()
    local char = self.player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    self.seat:Sit(humanoid)

    local LEG_PARTS_TO_REMOVE = {"RightFoot", "RightLowerLeg", "LeftFoot", "LeftLowerLeg"}
    local ATTACHMENTS_TO_REMOVE = {"BodyBackAttachment", "WaistBackAttachment", "HatAttachment"}

    local function setHatsAndLegsTransparency(obj, transparency)
        if obj:IsA("Humanoid") then
            obj = obj.Parent
        elseif obj:IsA("Player") then
            obj = obj.Character
        end

        for _, child in ipairs(obj:GetChildren()) do
            if not child:IsA("Accoutrement") then continue end
            local handle = child:FindFirstChild("Handle")
            if not handle then continue end
            local shouldRemove = false
            for _, attachmentName in ipairs(ATTACHMENTS_TO_REMOVE) do
                if handle:FindFirstChild(attachmentName) then
                    shouldRemove = true
                    break
                end
            end

            if shouldRemove then
                handle.Transparency = transparency
            end
        end

        for _, legName in ipairs(LEG_PARTS_TO_REMOVE) do
            local legPart = obj:FindFirstChild(legName)
            if legPart then
                legPart.Transparency = transparency
            end
        end
    end

    setHatsAndLegsTransparency(char, 1)
    self._maid:Add(function()
        self.humanoid.Sit = false
        setHatsAndLegsTransparency(char, 0)
        self.seat:SetNetworkOwnershipAuto()
        -- This is car state. Should I implement a vehicle as several separate player states?
        self.carObj.chassis:reset()
    end)

    -- Player is in the seat. It should have update input and gui on the client.
end

-- function CarDriverSeatS:_handleSeat()
--     self._maid:Add(self.seat:GetPropertyChangedSignal("Occupant"):Connect(function()
--         if self.seat.Occupant then
--             warn("Play start motor sound")
--             self:_handleDriver()
--         else
--             self:_destroyDriver()
--         end
--     end))
-- end

function CarDriverSeatS:_handleDriver()
    self._driverMaid = self._maid:Add(Maid.new(), nil, "DriverMaid")
    local occupant = self.seat.Occupant
    local char = occupant.Parent
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end
    self.seat:SetNetworkOwner(player)
    warn("Give player controllers")
    self._driverMaid:Add(function()
        warn("Destroy controllers")
        self.seat:SetNetworkOwner(nil)
    end)
end

function CarDriverSeatS:_destroyDriver()
    self._maid:Remove("DriverMaid")
end

function CarDriverSeatS:Destroy()
    self._maid:Destroy()
end

return CarDriverSeatS