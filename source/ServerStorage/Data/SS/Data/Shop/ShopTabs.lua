local Data = script:FindFirstAncestor("Data")
local Money = require(Data.Money.Money)
local S = require(Data.Strings.Strings)
local PrettyNames = require(Data.Strings.PrettyNames)

local module = {}

module.idData = {
    -- ["1"] = {
    --     name = S.MonsterSkins,
    --     prettyName = PrettyNames[S.MonsterSkins],
    --     LayoutOrder = 1,
    --     guiName = "MonsterSkinsController",
    -- },
    ["90"] = {
        name = "GamePasses",
        prettyName = "GamePasses",
        LayoutOrder = 90,
        guiName = "GamePassesController",
    },
    ["100"] = {
        name = S.Money_1,
        prettyName = Money[S.Money_1].prettyName,
        LayoutOrder = 100,
        guiName = "Money_1Controller",
    },
    ["110"] = {
        name = S.Trails,
        prettyName = "Trails",
        LayoutOrder = 100,
        guiName = "TrailsController",
    },
}

module.nameData = {}
for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module