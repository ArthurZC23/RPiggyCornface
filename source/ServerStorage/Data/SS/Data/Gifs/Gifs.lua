local module = {}

local baseDuration = 1/60
module.idData = {
    -- res: 286 x 289
    ["1"] = {
        textures = {},
    },
}

for _, data in pairs(module.idData) do
    data.configs = data.configs or {}
    data.configs["0"] = {}
    for _, texture in ipairs(data.textures) do
        table.insert(data.configs["0"], {
            decals = {
                {Texture = texture},
            },
            duration = baseDuration,
        })
    end
end

return module