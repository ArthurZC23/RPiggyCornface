local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = script:FindFirstAncestor("Data")
local DeveloperProducts = require(Data.DataStore.DeveloperProducts)

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local PrettyNames = require(Data.Strings.PrettyNames)
local S = require(Data.Strings.Strings)

local name = "Boosts"
local prettyName = name

local brightFactor = 0.5
local module = {
    thumbnail = {
        Image="rbxassetid://9348011525",
        ImageColor3=Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
    },
    prettyName = prettyName,
    color = Color3.fromRGB(17, 137, 229),

    developerProducts = {
        -- ["1248800142"] = {
        --     boostId = "1",
        --     name = S.AutoSell,
        --     thumbnail = {
        --         Image = "rbxassetid://9109760274",
        --     },
        --     gradient = {
        --         Color = ColorSequence.new({
        --             ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        --             ColorSequenceKeypoint.new(0.15, Color3.fromRGB(17, 216, 255):Lerp(Color3.fromRGB(255, 255, 255), brightFactor)),
        --             ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 216, 255)),
        --         }),
        --     },
        --     prettyName = {
        --         Text = "Auto Sell",
        --         TextColor3=Color3.fromRGB(255, 255, 255),
        --     },
        --     longDescription = {
        --         Text = "Automatically sells for you!",
        --         TextColor3=Color3.fromRGB(255, 255, 255),
        --     },
        --     LayoutOrder = 3,
        --     duration = "Lasts 10 minutes",
        --     priceInRobux = {},
        -- },
    },
}

for productId, localDevData in pairs(module.developerProducts) do
    localDevData.id = productId
    TableUtils.setProto(localDevData, {
        priceInRobux = {
            TextColor3=Color3.fromRGB(255, 255, 255),
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextStrokeTransparency = 0,
        },
    })
end

return module