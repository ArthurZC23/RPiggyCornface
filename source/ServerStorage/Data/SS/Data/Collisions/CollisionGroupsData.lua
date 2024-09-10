local module = {}

module.names = {
    ["Player"] = "Player",
    ["Npc"] = "Npc",
    ["CharCollision"] = "CharCollision",
    ["NoCollision"] = "NoCollision",
    ["Regions"] = "Regions",
    ["Default"] = "Default",
}

module.canGroupCollide = {
    {"Player", "Default", true},
    {"Player", "Player", false},
    {"Player", "Npc", false},
    {"Player", "CharCollision", true},
    {"Player", "NoCollision", false},
    {"Player", "Regions", false},

    {"Npc", "Default", true},
    {"Npc", "Npc", false},
    {"Npc", "CharCollision", true},
    {"Npc", "NoCollision", false},
    {"Npc", "Regions", false},

    {"CharCollision", "Default", false},
    {"CharCollision", "CharCollision", false},
    {"CharCollision", "NoCollision", false},
    {"CharCollision", "Regions", false},

    {"NoCollision", "Default", false},
    {"NoCollision", "NoCollision", false},
    {"NoCollision", "Regions", false},

    {"Regions", "Default", false},
    {"Regions", "Regions", true},
}

return module