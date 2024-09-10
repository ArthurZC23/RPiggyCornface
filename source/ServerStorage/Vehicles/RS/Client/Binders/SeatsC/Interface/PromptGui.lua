local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local VectorData = Data.Physics.Vectors
local SeatsData = Data.Vehicles.Car.Seats.Seats

local yHat = VectorData.unit.y

local PromptGui = {}
PromptGui.__index = PromptGui
PromptGui.className = "PromptGui"
PromptGui.TAG_NAME = PromptGui.className

local MIN_FLIP_ANGLE = 70
local function isFlipped(seat)
    local upVector = seat.CFrame.upVector
    local theta = math.deg(math.acos(upVector:Dot(yHat)))
    return theta >= MIN_FLIP_ANGLE
end

-- Create different prompts based on platform and if the vehicle is turned.
function PromptGui.new(carObj, seat)
    local self = {
        _maid = Maid.new(),
        carObj = carObj,
        seat = seat,
    }
    setmetatable(self, PromptGui)

    if not self:getFields() then return end

    self:setPrompt()
    self:handlePrompt()

    return self
end

function PromptGui:getFields()
    return SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.EnterVehicleRE = ComposedKey.getFirstDescendant(self.seat, {"Remotes", "Events", "EnterVehicle"})
            if not self.EnterVehicleRE then return end

            self.proximityPrompt = ComposedKey.getFirstDescendant(self.seat, {
                "PromptLocation", "ProximityPrompt"})
            if not self.proximityPrompt then return end

            return true
        end,
        keepTrying=function()
            return self.carObj.car.Parent
        end,
    })
end

function PromptGui:setPrompt()
    self.proximityPrompt.ObjectText = "Car"
    self.proximityPrompt.ActionText = "Enter"
    self.proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
    self.proximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonY
    self.proximityPrompt.Style = Enum.ProximityPromptStyle.Default
end

function PromptGui:handlePrompt()
    self.proximityPrompt.Triggered:Connect(function()
    -- I know the seat based on the remote
    self.EnterVehicleRE:FireServer()
    end)
end

function PromptGui:Destroy()
    self._maid:Destroy()
end

return PromptGui