local ReplicatedStorage = game:GetService("ReplicatedStorage")
for i, Monster in ipairs(ReplicatedStorage.Assets.Monsters.Monsters:GetChildren()) do
    local Sound = Monster.HumanoidRootPart:FindFirstChild("Sound")
    if Sound then Sound:Destroy() end
end