local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local module = {}

module.surfaces = {
    front=function (part) return part.CFrame.LookVector end,
    back=function (part) return -part.CFrame.LookVector end,
    top=function (part) return part.CFrame.UpVector end,
    bottom=function (part) return -part.CFrame.UpVector end,
    right=function (part) return part.CFrame.RightVector end,
    left=function (part) return -part.CFrame.RightVector end,
}
module.surfaces = Mts.makeEnum("Surfaces", module.surfaces)

module.unit = {
    x = Vector3.new(1, 0, 0),
    y = Vector3.new(0, 1, 0),
    z = Vector3.new(0, 0, 1),
    X = Vector3.new(1, 0, 0),
    Y = Vector3.new(0, 1, 0),
    Z = Vector3.new(0, 0, 1),
}
module.unit = Mts.makeEnum("UnitVectors", module.unit)

module.FAR_VECTOR = Vector3.new(-4e3, 0, 0)

return module