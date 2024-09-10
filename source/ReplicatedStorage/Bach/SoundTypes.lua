local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local module = {}

local soundTypes = {
    ["Soundtrack"]="Soundtrack", -- Only one can play at a time
	["Soundtrack3D"]="Soundtrack3D", -- e.g. monster Lemotif that only plays when near
	["Ambience"]="Ambience",
    ["Ambience3D"]="Ambience3D",
	["SfxGui"]="SfxGui",
    ["Sfx"]="Sfx",
	["Sfx3D"]="Sfx3D",
	["Voice"]="Voice", -- Character voice
	["Voice3D"]="Voice3D",
	["PlayerInteraction"] = "PlayerInteraction",
    ["PlayerInteraction3D"] = "PlayerInteraction3D",
}
module.soundTypes = Mts.makeEnum("SoundTypes", soundTypes)

return module