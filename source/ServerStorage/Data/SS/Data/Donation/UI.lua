local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = script:FindFirstAncestor("Data")
local DeveloperProducts = require(Data.DataStore.DeveloperProducts)
local PrettyNames = require(Data.Strings.PrettyNames)

local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)

local module = {}

local COLORS = {
    MAIN = Color3.fromRGB(255, 255, 255),
}

local name = "Donation"
local prettyName = PrettyNames[name]
module = {
    thumbnail = {
        Image="rbxassetid://6543591915",
        ImageColor3=Color3.fromRGB(255, 255, 255)
    },
    name = name,
    prettyName = prettyName,
    color = COLORS.MAIN,
    developerProducts = {
        ["1597666072"] = {
            LayoutOrder = 1,
        },
    },
}

-- for id, uiData in pairs(module.developerProducts) do
--     local devData = DeveloperProducts[id]
--     uiData.name = devData.name
--     uiData.baseValue = devData.baseValue
-- end
return module