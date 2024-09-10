local module = {}

module.tags = {
    ["0"] = {
        name = "noTag",
        viewName = "",
        guiName = "No Tag",
        tradable = false,
    },
    ["1"] = {
        name = "vip",
        viewName = "VIP",
    },
    ["2"] = {
        name = "contributor",
        viewName = "Contributor",
        tradable = false,
        groupRoleTag = true,
        role = "Contributor",
    },
    ["3"] = {
        name = "tester",
        viewName = "Tester",
        tradable = false,
        groupRoleTag = true,
        role = "QA Tester",
    },
    ["4"] = {
        name = "modTrainee",
        viewName = "Mod Trainee",
        tradable = false,
        groupRoleTag = true,
        role = "Moderator Trainee",
    },
    ["5"] = {
        name = "mod",
        viewName = "Mod",
        tradable = false,
        groupRoleTag = true,
        role = "Moderator",
    },
    ["6"] = {
        name = "testerLeader",
        viewName = "Tester Leader",
        tradable = false,
        groupRoleTag = true,
        role = "QA Leader",
    },
    ["7"] = {
        name = "admin",
        viewName = "Admin",
        tradable = false,
        groupRoleTag = true,
        role = "Admin",
    },
    ["8"] = {
        name = "commManager",
        viewName = "Community Manager",
        tradable = false,
        groupRoleTag = true,
        role = "Community Manager",
    },
    ["9"] = {
        name = "owner",
        viewName = "Owner",
        tradable = false,
        groupRoleTag = true,
        role = "Owner",
    },
}

module.chatTagDefault = {
    tagColor = "ffffff",
    nameColor = "ffffff",
    msgColor = "000000",
}

module.charColors = {
    ["ffffff"] = {
        name = "White",
    },
    ["c4281c"] = {
        name = "Red",
    },
    ["efb838"] = {
     name = "Gold",
    },
    ["da8541"] = {
        name = "Orange",
    },
    ["ff66cc"] = {
        name = "Pink",
    },
    ["0989cf"] = {
        name = "ElectricBlue",
    },
    ["4b974b"] = {
        name = "Green",
    },
    ["303030"] = {
        name = "Black",
    },
    ["7e683f"] = {
        name = "Bronze",
    },
    ["aa00aa"] = {
        name = "Magenta",
    },
}

return module