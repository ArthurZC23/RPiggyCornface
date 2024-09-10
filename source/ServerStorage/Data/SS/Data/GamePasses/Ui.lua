local GpData = require(script.Parent.GamePasses)
local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local MoneyData = require(Data.Money.Money)

local module = {}

local name = "GamePasses"
local prettyName = "Game Passes"

module = {
    name = name,
    prettyName = prettyName,
    thumbnail = {
        ImageColor3=Color3.fromRGB(255, 255, 255),
        Image = "",
    },
    color = Color3.fromRGB(10, 137, 195):Lerp(Color3.new(1, 1, 1), 0.1),
    gpProducts = {
        ["1"] = {
            name=S.VipGp,
            LayoutOrder = 1,
            shortDescription = {
                Text=("Vip"),
                TextColor3=Color3.fromRGB(255, 255, 255),
            },
            longDescription={
                Text=("Vip"),
                TextColor3=Color3.fromRGB(231, 7, 60),
                TextStrokeColor3 = Color3.new(0, 0, 0),
                TextStrokeTransparency = 0.5,
            },
            thumbnail = {},
            colors = {
                default=Color3.fromRGB(255, 255, 255),
                hover=Color3.fromRGB(233, 215, 19),
            },
            priceInRobux = {
                TextColor3=Color3.fromRGB(0, 255, 0),
            }
        },
        ["2"] = {
            name=S.MetalDipPack,
            LayoutOrder = 2,
            shortDescription = {
                Text=("Metal Dip Pack (x3)"),
                TextColor3=Color3.fromRGB(255, 255, 255),
            },
            longDescription={
                Text=("Metal Dip Pack (x3)"),
                TextColor3=Color3.fromRGB(231, 7, 60),
                TextStrokeColor3 = Color3.new(0, 0, 0),
                TextStrokeTransparency = 0.5,
            },
            thumbnail = {},
            colors = {
                default=Color3.fromRGB(255, 255, 255),
                hover=Color3.fromRGB(233, 215, 19),
            },
            priceInRobux = {
                TextColor3=Color3.fromRGB(0, 255, 0),
            }
        },
        ["3"] = {
            name=S.RainbowMonsterSkin,
            LayoutOrder = 3,
            shortDescription = {
                Text=("Rainbow Cornface"),
                TextColor3=Color3.fromRGB(255, 255, 255),
            },
            longDescription={
                Text=("Rainbow Cornface"),
                TextColor3=Color3.fromRGB(231, 7, 60),
                TextStrokeColor3 = Color3.new(0, 0, 0),
                TextStrokeTransparency = 0.5,
            },
            thumbnail = {},
            colors = {
                default=Color3.fromRGB(255, 255, 255),
                hover=Color3.fromRGB(233, 215, 19),
            },
            priceInRobux = {
                TextColor3=Color3.fromRGB(0, 255, 0),
            }
        },
    }
}

for _id, localGpData in pairs(module.gpProducts) do
    local data = GpData.nameToData[localGpData.name]
    module.gpProducts[_id]["id"] = data.id
end

-- module.thumbnail.Image = module.gpProducts[1].thumbnail.Image

return module