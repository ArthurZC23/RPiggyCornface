local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)
local lightingType = "default"
local LightingData = require(ServerStorage.Data.SS.Data.Lighting.Lighting).nameData[lightingType]

TableUtils.setInstance(Lighting, LightingData.props.Lighting)
for _, inst in ipairs(Lighting:GetChildren()) do
    TableUtils.setInstance(inst, LightingData.props[inst.Name])
end
for i, desc in ipairs(workspace:GetDescendants()) do
    if not desc:IsA("Light") then continue end
    desc.Enabled = true
end