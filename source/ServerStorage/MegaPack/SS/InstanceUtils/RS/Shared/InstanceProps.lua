local module = {}

function module.setTexture(inst, texture)
    if inst:IsA("MeshPart") then
        inst.TextureID = texture
    elseif inst:IsA("Texture") then
        inst.Texture = texture
    elseif inst:IsA("SpecialMesh") then
        inst.TextureId = texture
    elseif inst:IsA("Decal") then
        inst.Texture = texture
    end
end

function module.hasAny(inst, props)
    for _, prop in ipairs(props) do
        local has = module[("has%s"):format(prop)](inst)
        if has then return true end
    end
    return false
end

function module.hasTexture(inst)
    local classes = {MeshPart = true, Texture = true, SpecialMesh = true, Decal = true}
    return classes[inst.ClassName]
end

function module.hasImage(inst)
    local classes = {ImageLabel = true, ImageButton = true}
    return classes[inst.ClassName]
end

return module