local originalName = "ToolEquip_1"
local newName = "ToolEquip1"


for _, desc in ipairs(workspace:GetDescendants()) do
    if not desc:IsA("Pose") then continue end
    if desc.Name ~= originalName then continue end
    desc.Name = newName
end