local RunService = game:GetService("RunService")

if not RunService:IsStudio() then return end

local set = {}
local location = {}

for i, desc in ipairs(game:GetDescendants()) do
    if desc:IsA("ImageButton") or desc:IsA("ImageLabel") then
        local image = desc.Image
        set[image] = true
        location[image] = location[image] or {}
        table.insert(location[image], desc:GetFullName())
    end
    if desc:IsA("ParticleEmitter") then
        local image = desc.Texture
        set[image] = true
        location[image] = location[image] or {}
        table.insert(location[image], desc:GetFullName())
    end
    if desc:IsA("Beam") then
        local image = desc.Texture
        set[image] = true
        location[image] = location[image] or {}
        table.insert(location[image], desc:GetFullName())
    end
    if desc:IsA("Texture") then
        local image = desc.Texture
        set[image] = true
        location[image] = location[image] or {}
        table.insert(location[image], desc:GetFullName())
    end
    if desc:IsA("Decal") then
        local image = desc.Texture
        set[image] = true
        location[image] = location[image] or {}
        table.insert(location[image], desc:GetFullName())
    end
end

local materials = {
    ["rbxassetid://629019895"] = true, -- More than 512x512
    ["rbxassetid://10417152846"] = true, -- More than 512x512
    ["rbxassetid://10417156869"] = true, -- More than 512x512
    ["rbxassetid://10417159197"] = true -- 10417159197
}


for image in pairs(set) do
    print(image)
end

for image in pairs(materials) do
    print(image)
end

for image, instsNames in pairs(location) do
    for _, instName in ipairs(instsNames) do
        print(image, instName)
    end
end



