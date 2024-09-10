for i, Monster in ipairs(workspace.Studio.Tmp.Monsters.Monsters:GetChildren()) do
    local Toucher = Monster:FindFirstChild("Toucher")
    if Toucher then
        Toucher:Destroy()
    end
    local Attach = Monster.HumanoidRootPart:FindFirstChild("SRefMonsterToucher")
    if not Attach then
        Attach = Instance.new("Attachment")
        Attach.Name = "SRefMonsterToucher"
        Attach.CFrame = CFrame.new(0, -0.265, -0.066)
        Attach.Parent = Monster.HumanoidRootPart
    end
end