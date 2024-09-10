for _, desc in ipairs(workspace.Map:GetDescendants()) do
    if not desc:IsA("BasePart") then continue end
    desc.Anchored = true
end