local CollectionService = game:GetService("CollectionService")

for _, region in ipairs(CollectionService:GetTagged("Region")) do
    if region:GetAttribute("regionEditModeOffset") ~= nil then continue end
    local offset = 1e6 * Vector3.yAxis
    region.Position = region.Position + offset
    region:SetAttribute("regionEditModeOffset", offset)
end