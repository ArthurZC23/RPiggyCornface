local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local localPlayer = Players.LocalPlayer

-- Needs exit functions (maid)
-- Need vehicle root model

local VehicleSeatiing = {}
VehicleSeatiing.__index = VehicleSeatiing
VehicleSeatiing.className = "VehicleSeatiing"
VehicleSeatiing.TAG_NAME = VehicleSeatiing.className

function VehicleSeatiing.new(carObj)
    local self = {
        car = carObj.car,
        _maid = Maid.new(),
        currentHumanoid = nil,
        animationTracks = {},
        exitCallbacks = {},
    }
    setmetatable(self, VehicleSeatiing)

    local ok = self:getFields()
    if not ok then return end

    self.ExitSeatRE.OnClientEvent:Connect(function(doAntiTrip)
        for _, func in pairs(self.exitCallbacks) do
            func()
        end
        if doAntiTrip then self:antiTrip() end
    end)

    return self
end

function VehicleSeatiing:exitSeat()
    local humanoid = PlayerUtils.getHumanoidFromPlayer(localPlayer)
    if not humanoid then return end
    local char = humanoid.Parent
    if not humanoid.Sit then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, joint in ipairs(hrp:GetJoints()) do
        if joint.Name ~= "SeatWeld" then continue end
        -- Part0 is the seat
        local promptLocation = joint.Part0:FindFirstChild("PromptLocation")
        if not promptLocation then continue end
        local proximityPrompt = promptLocation:FindFirstChildWhichIsA("ProximityPrompt")
        if not (proximityPrompt and proximityPrompt.Name == "EndorsedVehicleProximityPromptV1") then continue end
        for _, cb in pairs(self.exitCallbacks) do cb(joint.Part0) end
        self.ExitSeatRE:FireServer()
        for _, track in pairs(self.animationTracks) do
            track:Stop()
        end
        return true
    end
end

function VehicleSeatiing:antiTrip()
	local humanoid = PlayerUtils.getHumanoidFromPlayer(localPlayer)
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function VehicleSeatiing:getFields()
    return SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.animationFolder = self.car:FindFirstChild("Animations")
            if not self.animationFolder then return end

            local Remotes = self.car:FindFirstChild("Remotes")
            if not Remotes then return end
            local Events = Remotes:FindFirstChild("Events")
            if not Events then return end
            self.ExitSeatRE = Events:FindFirstChild("ExitSeat")

            return true
        end,
        keepTrying=function()
        end,
    })
end

function VehicleSeatiing:Destroy()
    self._maid:Destroy()
end

return VehicleSeatiing