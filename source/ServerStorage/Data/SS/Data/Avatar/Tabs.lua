local module = {}

module.tabs1 = {
    human = {},
    dog = {},
}
module.tabs1.human.idData = {
    ["1"] = {
        name = "Accessory",
        prettyName = "Accessory",
        thumbnail = "",
        LayoutOrder = 1,
        guiName = "AvatarAccessoryController",
    },
    ["2"] = {
        name = "BodyParts",
        prettyName = "Body",
        thumbnail = "",
        LayoutOrder = 2,
        guiName = "AvatarBodyPartsController",
    },
    ["3"] = {
        name = "Clothing",
        prettyName = "Clothing",
        thumbnail = "",
        LayoutOrder = 3,
        guiName = "AvatarClothingController",
    },
    ["4"] = {
        name = "RpInfo",
        prettyName = "RP Info",
        thumbnail = "",
        LayoutOrder = 4,
        guiName = "RpInfoController",
    },
}
module.tabs1.dog.idData = {
    ["4"] = {
        name = "RpInfo",
        prettyName = "RP Info",
        thumbnail = "",
        LayoutOrder = 4,
        guiName = "RpInfoController",
    },
}

module.tabs1.human.nameData = {}
module.tabs1.dog.nameData = {}
for bodyType, tabs1 in pairs(module.tabs1) do
    for id, data in pairs(tabs1.idData) do
        data.id = id
        tabs1.nameData[data.name] = data
    end
end

module.tabs1.human.nameData["Accessory"].tabs2 = {
    ["1"] = {
        name = "Hat",
        prettyName = "Hat",
        LayoutOrder = 1,
    },
    ["2"] = {
        name = "Face",
        prettyName = "Face",
        LayoutOrder = 2,
    },
    ["3"] = {
        name = "Neck",
        prettyName = "Neck",
        LayoutOrder = 3,
    },
    ["4"] = {
        name = "Shoulder",
        prettyName = "Shoulder",
        LayoutOrder = 4,
    },
    ["5"] = {
        name = "Front",
        prettyName = "Front",
        LayoutOrder = 5,
    },
    ["6"] = {
        name = "Back",
        prettyName = "Back",
        LayoutOrder = 6,
    },
    ["7"] = {
        name = "Waist",
        prettyName = "Waist",
        LayoutOrder = 7,
    },
}
-- module.tabs1.dog.nameData["Accessory"].tabs2 = {}

module.tabs1.human.nameData["BodyParts"].tabs2 = {
    ["1"] = {
        name = "Hair",
        prettyName = "Hair",
        LayoutOrder = 1,
    },
    -- ["2"] = {
    --     name = "ClassicFace",
    --     prettyName = "Classic Face",
    --     LayoutOrder = 2,
    -- },
}

module.tabs1.human.nameData["Clothing"].tabs2 = {
    ["1"] = {
        name = "ClassicShirt",
        prettyName = "Classic Shirt",
        LayoutOrder = 1,
    },
    ["2"] = {
        name = "ClassicPants",
        prettyName = "Classic Pants",
        LayoutOrder = 2,
    },
}

return module