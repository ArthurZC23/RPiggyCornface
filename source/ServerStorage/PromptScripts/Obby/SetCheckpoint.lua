local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Models = ReplicatedStorage.Assets.Models
local correctCheckpointProto = Models.Checkpoint:Clone()

for _, Checkpoint in ipairs(workspace.Map.Obby:GetDescendants()) do
    if Checkpoint.Name ~= "Checkpoint" then continue end
    if Checkpoint.Parent.Name ~= "Start" then continue end
    for _, child in ipairs(Checkpoint:GetChildren()) do
        if child.Size == Vector3.new(16, 1, 12) then
            local newCheckpoint = correctCheckpointProto:Clone()
            newCheckpoint.Parent = Checkpoint.Parent
            newCheckpoint:PivotTo(Checkpoint:GetPivot())
            Checkpoint:Destroy()
            break
        end
    end
end

for _, Checkpoint in ipairs(workspace.Map.Obby:GetDescendants()) do
    if Checkpoint.Name ~= "Checkpoint" then continue end
    if Checkpoint.Parent.Name ~= "Start" then continue end
    CollectionService:AddTag(Checkpoint, "Checkpoint")
end
