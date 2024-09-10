local CollectionService = game:GetService("CollectionService")

for _, region in ipairs(CollectionService:GetTagged("Region")) do
    local offset = region:GetAttribute("regionEditModeOffset")
    if offset == nil then continue end
    region.Position = region.Position - offset
    region:SetAttribute("regionEditModeOffset", nil)
end