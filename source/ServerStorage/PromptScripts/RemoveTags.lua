CollectionService = game:GetService("CollectionService")

inst = workspace.Studio.Tmp.Puppet

for _, tag in ipairs(CollectionService:GetAllTags()) do
    CollectionService:RemoveTag(inst, tag)
end