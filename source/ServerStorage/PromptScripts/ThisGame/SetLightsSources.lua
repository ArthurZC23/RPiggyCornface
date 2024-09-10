for i, desc in ipairs(workspace:GetDescendants()) do
    if not desc:IsA("Light") then continue end
    desc.Enabled = true
end