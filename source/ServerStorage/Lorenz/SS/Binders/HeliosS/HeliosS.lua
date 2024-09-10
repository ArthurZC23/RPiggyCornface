local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local LorenzData = Data.Lorenz.Lorenz
local SingletonsManager = Mod:find({"Singleton", "Manager"})

local HeliosS = {}
HeliosS.__index = HeliosS
HeliosS.className = "Helios"
HeliosS.TAG_NAME = HeliosS.className

function HeliosS.new()
    local self = {}
    setmetatable(self, HeliosS)

    self:setLighting()
    -- self:startTimePassage()
    return self
end

local TableUtils = Mod:find({"Table", "Utils"})
function HeliosS:setLighting()
    if Data.Studio.Studio.disableLights then return end

    local LightingData = Data.Lighting.Lighting.nameData["default"]
    TableUtils.setInstance(Lighting, LightingData.props.Lighting)
    for _, inst in ipairs(Lighting:GetChildren()) do
        TableUtils.setInstance(inst, LightingData.props[inst.Name])
    end
    for i, desc in ipairs(workspace:GetDescendants()) do
        if not desc:IsA("Light") then continue end
        desc.Enabled = true
    end
end

-- Put on client if activate again
-- function HeliosS:startTimePassage()
--     local minutesAfterMidnight = LorenzData.startTimeInMin
--     Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)
--     FastSpawn(function ()
--         while true do
--             Cronos.wait(LorenzData.realTimeStepInSeconds)
--             minutesAfterMidnight = (minutesAfterMidnight + LorenzData.robloxTimeStepInMinutes) % LorenzData.minutesInADay
--             workspace:SetAttribute("TimeOfDay", minutesAfterMidnight)
--         end
--     end)
-- end

function HeliosS:Destroy()
    self._maid:Destroy()
end

-- SingletonsManager.addSingleton(HeliosS.className, HeliosS.new())

return HeliosS