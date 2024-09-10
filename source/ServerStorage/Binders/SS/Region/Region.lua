local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GameData = Data.Game.Game
local Collisions = Mod:find({"Collisions"})
local CollisionsGroups = Data.Collisions.CollisionGroupsData

local Region = {}
Region.__index = Region
Region.className = "Region"
Region.TAG_NAME = Region.className

function Region.new(region)
    Collisions.setCollisionGroupRecursive(region, CollisionsGroups.names.Regions)
end

function Region:Destroy()

end

return Region