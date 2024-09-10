local RunService = game:GetService("RunService")

if not RunService:IsStudio() then return end

for i, desc in ipairs(game:GetDescendants()) do
    if desc:IsA("PointLight") or desc:IsA("SurfaceLight") or  desc:IsA("SpotLight") then
        desc:Destroy()
    end
end
