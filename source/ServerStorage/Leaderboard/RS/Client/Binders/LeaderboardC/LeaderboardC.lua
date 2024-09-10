local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local Leaderboard = {}
Leaderboard.__index = Leaderboard
Leaderboard.className = "Leaderboard"
Leaderboard.TAG_NAME = Leaderboard.className

local ONE_MINUTE = 60
-- if RunService:IsStudio() then ONE_MINUTE = 10 end

Leaderboard.updateEventsTimestamps = {}

function Leaderboard.new(leaderboard)
    if not leaderboard:FindFirstAncestorOfClass("Workspace") then return end
    local self = {
        _maid = Maid.new(),
        leaderboard = leaderboard,
        isNear = nil,
        screen = leaderboard:FindFirstAncestorWhichIsA("BasePart"),
    }
    setmetatable(self, Leaderboard)

    local proximityPrompt = self:addProximityPrompt()

    FastSpawn(function()
        -- Use screen because every leaderboard of the same type in that place can reuse it.
        self.UpdateRE = self.screen
            :WaitForChild("Remotes")
            :WaitForChild("Events")
            :WaitForChild("Update")

        proximityPrompt.PromptHidden:Connect(function()
            self.isNear = false
        end)

        proximityPrompt.PromptShown:Connect(function()
            self.isNear = true
            self:requestUpdate()
        end)
    end)

    return self
end

function Leaderboard:addProximityPrompt()
    local attach = GaiaShared.create("Attachment", {
        Parent = self.screen,
        Name = "LeaderboardAttach"
    })

    local proximityPrompt = GaiaShared.create("ProximityPrompt", {
        Parent = attach,
        ClickablePrompt = false,
        Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow,
        GamepadKeyCode = Enum.KeyCode.ButtonL3, -- Dummy
        KeyboardKeyCode = Enum.KeyCode.Help, -- Dummy
        MaxActivationDistance = 80,
        ObjectText = "",
        RequiresLineOfSight = true,
        Style = Enum.ProximityPromptStyle.Custom,
    })

    return proximityPrompt
end

function Leaderboard:requestUpdate()
    repeat
        -- print("Request Leaderboard Update on client")
        local t = Cronos:getTime()
        local t0 = Leaderboard.updateEventsTimestamps[self.UpdateRE] or 0
        if t - t0 < 0.95 * ONE_MINUTE then
            Cronos.wait(10)
        else
            self.UpdateRE:FireServer()
            Leaderboard.updateEventsTimestamps[self.UpdateRE] = Cronos:getTime()
            Cronos.wait(ONE_MINUTE)
        end
    until not self.isNear
    --print("Finish")
end

function Leaderboard:Destroy()
    self._maid:Destroy()
end

return Leaderboard