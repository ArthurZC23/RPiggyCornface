local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")

local Data = script:FindFirstAncestor("Data")
local ServerTypesData = require(Data.Game.ServerTypes)

Lighting.GlobalShadows = true

local module = {}

module.chapter = "1"
module.maxLives = 6
module.buyNewLifeDuration = 15

local tokens = 0
for _, inst in ipairs(CollectionService:GetTagged("MapToken")) do
    if not inst:IsDescendantOf(workspace) then continue end
    tokens += 1
end
module.numberTokens = tokens

local envs = {
    [ServerTypesData.sTypes.StudioNotPublished] = true,
    [ServerTypesData.sTypes.StudioPublishedPrivate] = true,
    [ServerTypesData.sTypes.StudioPublishedTest] = true,
    [ServerTypesData.sTypes.StudioPublishedProduction] = true,
}
if envs[ServerTypesData.ServerType] then
    -- module.buyNewLifeDuration = 4
end

return module