local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local ScoresData = require(Data.Scores.Scores)

local module = {
    {
        stateType = S.Stores,
        scope = S.Money_1,
    },
}

for _, data in ipairs(module) do
    data.event = data.event or "Increment"
    data.scoreType = data.scoreType or ScoresData.scoreTypes[data.scope]
    data.valueKey = data.valueKey or "value"
end

return module