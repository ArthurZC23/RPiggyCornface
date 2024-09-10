local RunService = game:GetService("RunService")

if not RunService:IsStudio() then return end

local imgs = {
    ["321649430"] = true,
    ["939430651"] = true,
    ["186405730"] = true,
}

for i, desc in ipairs(game:GetDescendants()) do
    if desc:IsA("BasePart") then
        desc.MaterialVariant = ""
    elseif desc:IsA("SurfaceAppearance")  then
        desc:Destroy()
    end
end