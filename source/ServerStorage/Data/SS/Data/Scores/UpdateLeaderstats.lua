local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))

local Data = script:FindFirstAncestor("Data")
local PrettyNames = require(Data.Strings.PrettyNames)
local S = require(Data.Strings.Strings)
local MoneyData = require(Data.Money.Money)
local PlayerSessionScoresData = require(Data.Scores.PlayerScores.PlayerSessionScores)
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})

local module = {
    -- {
    --     stateManager = "playerState",
    --     stateType = S.Stores,
    --     scope = S.Money_1,
    --     prettyName = MoneyData[S.Money_1].prettyName,
    --     type_ = "StringValue",
    --     eventName = "Update",
    --     update = function(statV, state)
    --         statV.Value = NumberFormatter.numberToEng(state.current)
    --     end,
    -- },
    {
        stateManager = "playerState",
        stateType = S.Stores,
        scope = "Scores",
        prettyName = PrettyNames[S.FinishChapter],
        type_ = "StringValue",
        eventName = "set",
        update = function(statV, state)
            statV.Value = NumberFormatter.numberToEng(state[S.FinishChapter]["allTime"])
        end,
    },
    -- {
    --     stateManager = "playerState",
    --     stateType = S.Stores,
    --     scope = "Scores",
    --     prettyName = PrettyNames[S.FinishChapter1],
    --     type_ = "StringValue",
    --     eventName = "set",
    --     update = function(statV, state)
    --         statV.Value = NumberFormatter.numberToEng(state[S.FinishChapter1]["allTime"])
    --     end,
    -- },
}

return module