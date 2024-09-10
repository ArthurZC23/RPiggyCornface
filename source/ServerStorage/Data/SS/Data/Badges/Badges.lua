local Data = script:FindFirstAncestor("Data")
local DsbConfig = require(Data.DataStore.DsbConfig)

local module = {}

module.nameToId = {
    ["Welcome"] = DsbConfig.dataValidationBadge,
}

return module