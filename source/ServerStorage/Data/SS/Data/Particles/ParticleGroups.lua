local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Particles = Assets.Particles

local module = {}

module.groups = {}
module.groupsConfigs = {}
module.groupsEmissions = {}

return module