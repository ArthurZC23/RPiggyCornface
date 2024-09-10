local StarterGui = game:GetService("StarterGui")

for _, child in ipairs(StarterGui:GetChildren()) do
    local code = child:FindFirstChild("Code")
    if code then
        code:Destroy()
    end
end