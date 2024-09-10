local CollectionService = game:GetService("CollectionService")

for _, Checkpoint in ipairs(game:GetDescendants()) do
    if Checkpoint.Name ~= "Checkpoint" then continue end
    if Checkpoint.Parent.Name ~= "Start" then continue end
    CollectionService:AddTag(Checkpoint, "Checkpoint")
end
