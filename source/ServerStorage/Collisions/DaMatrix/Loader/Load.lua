local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local CollisionGroupsData = Data.Collisions.CollisionGroupsData
local GaiaShared = Mod:find({"Gaia", "Shared"})

for cg in pairs(CollisionGroupsData.names) do
    if cg == "Default" then continue end
    PhysicsService:RegisterCollisionGroup(cg)
end

for _, data in ipairs(CollisionGroupsData.canGroupCollide) do
    PhysicsService:CollisionGroupSetCollidable(data[1], data[2], data[3])
end

local CollisionsRsFolder = ComposedKey.getAsync(ReplicatedStorage, {"Collisions"})
GaiaShared.create("BoolValue", {
    Name = "AreCollisionsLoaded",
    Value = true,
    Parent = CollisionsRsFolder
})

local module = {}

return module