local CollectionService = game:GetService("CollectionService")

for _, desc in ipairs(workspace.Map.Obby:GetDescendants()) do
    if not CollectionService:HasTag(desc, "LavaBlock") then continue end
    CollectionService:AddTag(desc, "KillBlock")
    CollectionService:RemoveTag(desc, "LavaBlock")
    desc:SetAttribute("CSSClass", nil)
end

for _, desc in ipairs(workspace.Map.Obby:GetDescendants()) do
    if not CollectionService:HasTag(desc, "KillBlock") then continue end
    CollectionService:AddTag(desc, "KillBlock")
    CollectionService:RemoveTag(desc, "CSS")
end
