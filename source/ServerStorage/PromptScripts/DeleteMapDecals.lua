local RunService = game:GetService("RunService")

if not RunService:IsStudio() then return end

local decals = {
    ["rbxassetid://8632727843"] = true
}

local map = workspace.Map.Arena.Arena.Map

for i, desc in ipairs(map:GetDescendants()) do
    if not (desc:IsA("Decal") or desc:IsA("Texture")) then continue end
    if decals[desc.Texture] then
        desc:Destroy()
    end
end