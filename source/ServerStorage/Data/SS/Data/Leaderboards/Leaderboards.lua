local ServerStorage = game:GetService("ServerStorage")

local Data = script:FindFirstAncestor("Data")
local ScoresData = require(Data.Scores.Scores)

local DataStoreService = require(ServerStorage.DataStoreService)

local module = {}

-- module["1"] = {
--     scoreType = ScoresData.scoreTypes.Money_1,
--     timeType = ScoresData.timeTypes.allTime,
-- }

-- module["2"] = {
--     scoreType = ScoresData.scoreTypes.FinishChapter,
--     timeType = ScoresData.timeTypes.allTime,
-- }

-- module["3"] = {
--     scoreType = ScoresData.scoreTypes.FinishChapter1,
--     timeType = ScoresData.timeTypes.allTime,
-- }

-- module["4"] = {
--     scoreType = ScoresData.scoreTypes.Kills,
--     timeType = ScoresData.timeTypes.allTime,
-- }

for id, data in pairs(module) do
    data.maxNumberEntries = data.maxNumberEntries or 100
    assert(data.maxNumberEntries <= 100 and data.maxNumberEntries > 0, ("Max Number Entries %s is not valid for leaderboard"):format(data.maxNumberEntries))

    data.ODataStore = DataStoreService:GetOrderedDataStore(
        ("Leaderboard/%s"):format(data.scoreType),
        data.timeType
    )
end

return module