local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local StudioData = require(Data.Studio.Studio)
local MoneyData = require(Data.Money.Money)

local module = {}

module.data = {
    -- {
    --     name=S.x2Money_1Gp,
    --     prettyName = ("x2 %s"):format(MoneyData[S.Money_1].prettyName),
    --     color = Color3.fromRGB(200, 200, 0),
    --     id="830143798",
    --     mockId = ""
    -- },
}
local function createMappings()
    module.nameToData = {}
    module.idToData = {}
    if RunService:IsStudio() and game.PlaceId == 0 and StudioData.gps.useMockGps then
        warn("Using mockId for Gps.")
    end
    for _, data in pairs(module.data) do
        if RunService:IsStudio() and game.PlaceId == 0 and StudioData.gps.useMockGps then
            data.id = data.mockId
        end
        data.mockId = nil
        module.nameToData[data.name] = data
        module.idToData[data.id] = data
    end
end
createMappings()

return module