local RunService = game:GetService("RunService")

if not RunService:IsStudio() then return end

local imgs = {
    ["6412503613"] = true,
    ["6444884337"] = true,
    ["6444884785"] = true,
}

for i, desc in ipairs(game:GetDescendants()) do
    if desc:IsA("ImageButton") or desc:IsA("ImageLabel") then
        local image = desc.Image
        for img in pairs(imgs) do
            if image:match(img) then
                print(("Asset %s has image."):format(desc:GetFullName()))
            end
        end
    end
    if desc:IsA("ParticleEmitter") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                print(("Asset %s has image."):format(desc:GetFullName()))
            end
        end
    end
    if desc:IsA("Beam") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                print(("Asset %s has image."):format(desc:GetFullName()))
            end
        end
    end
    if desc:IsA("Texture") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                print(("Asset %s has image."):format(desc:GetFullName()))
            end
        end
    end
    if desc:IsA("Decal") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                print(("Asset %s has image."):format(desc:GetFullName()))
            end
        end
    end
end