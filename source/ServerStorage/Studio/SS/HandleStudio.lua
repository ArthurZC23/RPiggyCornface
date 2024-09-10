local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})

local module = {}

function module.excludeStudioInstances()
    if not RunService:IsStudio() then
        FastSpawn(function()
            local StudioF = workspace.Studio
            StudioF.Parent = nil
            for _, child in ipairs(StudioF:GetChildren()) do
                child:Destroy()
                Cronos.wait(1)
            end
        end)
    end
end


return module