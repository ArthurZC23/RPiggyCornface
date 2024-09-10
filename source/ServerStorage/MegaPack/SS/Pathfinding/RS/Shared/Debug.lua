local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaShared = Mod:find({"Gaia", "Shared"})

local module = {}

function module.showWps(wps, parent)
    if not RunService:IsStudio() then return end
    for _, child in ipairs(parent:GetChildren()) do
        child:Destroy()
    end
    for i, wp in ipairs(wps) do
        local wpPart = GaiaShared.create("Part", {
            Name = tostring(i),
            Size = Vector3.new(1, 1, 1),
            Position = wp.Position,
            Color = Color3.fromRGB(25, 255, 224),
            Anchored = true,
            CanCollide = false,
            Transparency = 0.5,
            Parent = parent
        })
    end
end

return module