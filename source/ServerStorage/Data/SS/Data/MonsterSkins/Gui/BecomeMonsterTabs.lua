local module = {}

module.idData = {
    ["1"] = {
        name = "BecomeMonster",
        LayoutOrder = 1,
        guiName = "BecomeMonsterController",
    },
    ["2"] = {
        name = "ChangeMonsterSkin",
        LayoutOrder = 2,
        guiName = "ChangeMonsterSkinController",
    },
}

module.nameData = {}
for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module