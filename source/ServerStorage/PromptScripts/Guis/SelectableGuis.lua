for _, desc in ipairs(game:GetDescendants()) do
    if not desc:IsA("GuiObject") then continue end
    if not (desc:IsA("GuiButton") or desc:IsA("TextBox")) then
        desc.Selectable = false
        continue
    end
    if desc:GetAttribute("IsSelectable") == false then
        desc.Selectable = false
        continue
    end
    desc.Selectable = true
end