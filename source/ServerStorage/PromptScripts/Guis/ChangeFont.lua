for _, text in ipairs(game:GetDescendants()) do
    if not (text:IsA("TextButton") or text:IsA("TextLabel") or text:IsA("TextBox")) then continue end
    text.Font = Enum.Font.ArialBold
end