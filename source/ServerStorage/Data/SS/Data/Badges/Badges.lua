local Data = script:FindFirstAncestor("Data")
local DsbConfig = require(Data.DataStore.DsbConfig)

local module = {}

module.nameToId = {
    ["Welcome"] = DsbConfig.dataValidationBadge,
    ["Winner"] = "2279374984077069",
    ["Chapter 1"] = "2520943207948003",
    ["Played_15MinSession"] = "1367723862477680",
    ["Played_30MinTotal"] = "2214578412059334",
}

return module