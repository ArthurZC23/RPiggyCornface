local Data = script:FindFirstAncestor("Data")
local GamePassesData = require(Data.GamePasses.GamePasses)

local module = {}
module.idData = {}

for gpId, data in pairs(GamePassesData.idToData) do
    module.idData[gpId] = {
        name = data.name,
        prettyName = data.prettyName,
        color = data.color,
    }
end

return module