local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})
local Maid = Mod:find({"Maid"})
local TableUtils = Mod:find({"Table", "Utils"})

local GeometricSampler = {}
GeometricSampler.__index = GeometricSampler
GeometricSampler.className = "GeometricSampler"
GeometricSampler.TAG_NAME = GeometricSampler.className

function GeometricSampler.new()
    local self = {}
    setmetatable(self, GeometricSampler)
    self._maid = Maid.new()
    self.random = Random.new()

    return self
end

function GeometricSampler:sampleBox(boxPart)
    local pos = boxPart.Position
    local size = boxPart.Size
    local sample =
        pos +
        self.random:NextNumber(-0.5, 0.5) * size * Vector3.new(1, 1, 1)
    return sample
end

function GeometricSampler:Destroy()
    self._maid:Destroy()
end

return GeometricSampler