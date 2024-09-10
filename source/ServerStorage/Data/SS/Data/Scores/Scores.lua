local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local PrettyNames = require(Data.Strings.PrettyNames)

local module = {}

module.scoreTypes = {
    -- [S.Points] = S.Points,
    [S.Money_1] = S.Money_1,
    [S.TimePlayed] = S.TimePlayed,
    [S.FinishChapter] = S.FinishChapter,
    [S.FinishChapter1] = S.FinishChapter1,
    [S.Kills] = S.Kills,
    -- [S.Donation] = S.Donation,
}
module.scoreTypes = Mts.makeEnum("ScoreTypes", module.scoreTypes)

module.prettyNames = {}
for scoreName in pairs(module.scoreTypes) do
    module.prettyNames[scoreName] = PrettyNames[scoreName]
end

module.timeTypes = {
    allTime = "allTime",
}

module.timeTypes = Mts.makeEnum("TimeType", module.timeTypes)

return module