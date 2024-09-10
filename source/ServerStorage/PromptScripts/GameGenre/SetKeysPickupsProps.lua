for i, Key in ipairs(workspace.Map.Chapters["1"].Puzzles.Keys:GetChildren()) do
    for _, desc in ipairs(Key:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.CastShadow = false
        desc.CanCollide = false
        desc.CanTouch = true
        desc.CanQuery = true
        desc.Anchored = true
    end
end