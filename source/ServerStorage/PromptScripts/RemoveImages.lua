local RunService = game:GetService("RunService")

if not RunService:IsStudio() then return end

local imgs = {
    ["321649430"] = true,
    ["939430651"] = true,
    ["186405730"] = true,
}

for i, desc in ipairs(game:GetDescendants()) do
    if desc:IsA("ImageButton") or desc:IsA("ImageLabel") then
        local image = desc.Image
        for img in pairs(imgs) do
            if image:match(img) then
                desc.Image = ""
            end
        end
    end
    if desc:IsA("ParticleEmitter") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                desc.Texture = ""
            end
        end
    end
    if desc:IsA("Beam") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                desc.Texture = ""
            end
        end
    end
    if desc:IsA("Texture") then
        local image = desc.Texture
        for img in pairs(imgs) do
            print(image, "/", img)
            if image:match(img) then
                print(img)
                desc.Texture = ""
            end
        end
    end
    if desc:IsA("Decal") then
        local image = desc.Texture
        for img in pairs(imgs) do
            if image:match(img) then
                desc.Texture = ""
            end
        end
    end
end