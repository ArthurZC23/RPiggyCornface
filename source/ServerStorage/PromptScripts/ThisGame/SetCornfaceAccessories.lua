for _, Char in ipairs(workspace.Studio.Rigs.Monster:GetChildren()) do
    if not Char:IsA("Model") then continue end
    for _, inst in ipairs(Char.Accessories:GetDescendants()) do
        if not inst:IsA("BasePart") then continue end
        inst.CastShadow = true
        inst.CanCollide = false
        inst.CanTouch = false
        inst.CanQuery = false
        inst.Anchored = false
        inst.Massless = true
        if not inst:GetAttribute("transpDefault") then
            inst:SetAttribute("transpDefault", 0)
        end

        if inst.Name == "cornbase" or inst.Name == "InnerBody" then
            if inst:FindFirstChild("WeldConstraint") then
                inst.WeldConstraint:Destroy()
            elseif not inst:FindFirstChild("WeldBody") then
                local WeldConstraint = Instance.new("WeldConstraint")
                WeldConstraint.Part0 = inst
                WeldConstraint.Part1 = Char.UpperTorso
                WeldConstraint.Name = "WeldBody"
                WeldConstraint.Parent = inst
            end
        end

        if inst.Name == "cornbase" then
            inst.Name = "InnerBody"
        end
    end
    if Char.Head:FindFirstChild("face") then
        Char.Head.face:Destroy()
    end
    Char.Head:SetAttribute("transpDefault", 1)
    Char.UpperTorso:SetAttribute("transpDefault", 1)
    Char.LowerTorso:SetAttribute("transpDefault", 1)
end
