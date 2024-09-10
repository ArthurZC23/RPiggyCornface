local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})


local Data = script:FindFirstAncestor("Data")
local ScoresData = require(Data.Scores.Scores)
local S = require(Data.Strings.Strings)
local MoneyData = require(Data.Money.Money)
local PrettyNames = require(Data.Strings.PrettyNames)

local module = {
    scoresList = {
        -- {
        --     name = ScoresData.scoreTypes.Points,
        --     prettyName = MoneyData[S.Points].prettyName,
        -- },
    }
}

module.scoresList = Mts.makeEnum("ScoresList", module.scoresList)

return module