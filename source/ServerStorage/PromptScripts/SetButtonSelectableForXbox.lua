for _, desc in ipairs(game:GetDescendants()) do
    if
        desc:IsA("TextButton")
        or desc:IsA("ImageButton")
        or desc:IsA("TextBox")
    then
        if not desc.Active then continue end
        desc.Selectable = true
    end
end