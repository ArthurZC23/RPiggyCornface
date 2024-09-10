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

    }
}

for _id, localGpData in pairs(module.gpProducts) do
    local data = GpData.nameToData[localGpData.name]
    module.gpProducts[_id]["id"] = data.id
end

-- module.thumbnail.Image = module.gpProducts[1].thumbnail.Image

return module