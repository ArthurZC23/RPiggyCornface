local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Data = Mod:find({"Data", "Data"})
local TimeUnits = Data.Date.TimeUnits
local minute = TimeUnits.minute

local RootF = script:FindFirstAncestor("SS")

local DataAsyncModules = require(RootF.DataAsyncModules.DataAsyncModules)

local cooldown = 5 * minute
-- if RunService:IsStudio() then
--     cooldown = 15
-- end

FastSpawn(function()
    -- if RunService:IsStudio() then
    --     Cronos.wait(180)
    -- end

    while true do
        for funcName, updateFunc in pairs(DataAsyncModules) do
            updateFunc()
        end
        Cronos.wait(cooldown)
    end
end)

return {}