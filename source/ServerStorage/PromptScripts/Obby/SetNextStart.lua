local CollectionService = game:GetService("CollectionService")

for _, Checkpoint in ipairs(workspace.Map.Obby:GetDescendants()) do
    if Checkpoint.Name ~= "Checkpoint" then continue end
    local Stage = Checkpoint.Parent.Parent
    local NextStart = Stage.Finish.Skeleton.NextStart
    NextStart.CanCollide = false
    NextStart.CanTouch = false
    CollectionService:RemoveTag(NextStart, "MetaPart")
end

-------------------------------------


local CollectionService = game:GetService("CollectionService")

for _, desc in ipairs(game:GetDescendants()) do
    if CollectionService:HasTag(desc, "MetaPart") then
        print(desc:GetFullName())
    end
end