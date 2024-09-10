local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {
    [S.Robux] = {
        prettyName = "Robux",
        thumbnail = "rbxassetid://8851226606",
        color = Color3.fromRGB(255, 255, 255),
        LayoutOrder = 1e3,
    },
    [S.Money_1] = {
        prettyName = "Coins",
        viewNameSingular = "Coins",
        thumbnail = "rbxassetid://6543591915",
        color = Color3.fromRGB(241, 241, 0),
        LayoutOrder = 1,
    },
    [S.MoneyMonster] = {
        prettyName = "Gems",
        viewNameSingular = "Gem",
        thumbnail = "rbxassetid://17769791063",
        color = Color3.fromRGB(0, 116, 241),
        LayoutOrder = 2,
    },
}

return module