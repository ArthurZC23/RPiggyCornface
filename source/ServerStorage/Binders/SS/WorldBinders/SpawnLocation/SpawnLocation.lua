local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Collisions = Mod:find({"Collisions"})
local CollisionsGroups = Data.Collisions.CollisionGroupsData

local SpawnLocation = {}
SpawnLocation.__index = SpawnLocation
SpawnLocation.className = "SpawnLocation"
SpawnLocation.TAG_NAME = SpawnLocation.className

function SpawnLocation.new(part)
    Collisions.setCollisionGroupRecursive(part, CollisionsGroups.names.NoCollision)
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Transparency = 1
end

function SpawnLocation:Destroy()

end

return SpawnLocation