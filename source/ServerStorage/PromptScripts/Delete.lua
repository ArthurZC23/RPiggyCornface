local Root = workspace.Map.Arena.Arena.Map

for i, desc in ipairs(Root:GetDescendants()) do
    if not (desc:IsA("Weld") or desc:IsA("WeldConstraint")) then continue end
    desc:Destroy()
end