local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local module = {}

module.className = {}
local BasePart = {"CastShadow", "Color", "Material", "MaterialVariant", "Reflectance", "Transparency"}
module.className.Part = BasePart
module.className.CornerWedgePart = BasePart
module.className.TrussPart = BasePart
module.className.WedgePart = BasePart
module.className.MeshPart = TableUtils.concatArrays(BasePart, {"DoubleSided", "TextureID"})

module.className.Decal = {"Color3", "Texture", "Transparency", "ZIndex"}
module.className.Texture = TableUtils.concatArrays(
    module.className.Decal, {"OffsetStudsU", "OffsetStudsV", "StudsPerTileU", "StudsPerTileV"}
)

module.className.Beam = {
    "Color", "Enabled", "LightEmission", "LightInfluence",
    "Texture", "TextureLength", "TextureMode", "TextureSpeed",
    "Transparency", "ZOffset",
}

-- Incomplete
module.className.ParticleEmitter = {
    "Color", "LightEmission", "LightInfluence", "Orientation",
    "Size", "Squash", "Texture", "Transparency", "ZOffset",
    "EmissionDirection", "Enabled", ""
}

module.className.BodyColors = {
    
}

return module