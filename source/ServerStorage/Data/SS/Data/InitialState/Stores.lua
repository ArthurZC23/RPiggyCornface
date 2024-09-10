local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = script:FindFirstAncestor("Data")
local ScoresData = require(Data.Scores.Scores)
local S = require(Data.Strings.Strings)
local FastModeData = require(Data.Settings.FastMode)
local GpData = require(Data.GamePasses.GamePasses)
local TrailsData = require(Data.Trails.Trails)

-- One disadvantage of this method is that the I need to remember how to structure data while setting values.
-- Not really. I can use CustomStateOnStudio to set a state. Save on TEST place then export and paste it here.
-- One advantage is that I can import player values and replicate their state
local module = {}

module.studio = {
    ["925418276"] = {
        Money_1 = {
            current = 2e3,
        },
        -- MonsterSkins = {
        --     eq = "1",
        --     st = {
        --         ["1"] = {},
        --     },
        -- },
        -- MoneyMonster = {
        --     current = 10,
        -- },
        -- GamePasses = {
        --     st = {
        --         ["10"] = {},
        --     }
        -- },
        -- Scores = {
        --     [S.Money_1] = {
        --         allTime = 100,
        --     },
        --     [S.FinishChapter] = {
        --         allTime = 5,
        --     },
        --     [S.FinishChapter1] = {
        --         allTime = 4,
        --     },
        --     [S.TimePlayed] = {
        --         allTime = 0,
        --     },
        -- },
    },
    ["-1"] = {
        Money_1 = {
            current = 1e3,
        },
        MoneyMonster = {
            current = 10,
        },
    },
    ["-2"] = {
        Money_1 = {
            current = 1e3,
        },
        MoneyMonster = {
            current = 10,
        },
    },
    ["-3"] = {

    },
    ["-4"] = {

    },
    ["-5"] = {

    },
    ["Proto"] = {

    },
}

-- Gamepasses
-- module.studio["925418276"].GamePasses = module.studio["925418276"].GamePasses or {
--     st = {}
-- }
-- for id, data in pairs(GpData.idToData) do
--     module.studio["925418276"].GamePasses.st[id] = {}
-- end

-- Trails
-- module.studio["925418276"].Trails = module.studio["925418276"].Trails or {
--     st = {}
-- }
-- for id, data in pairs(TrailsData.idData) do
--     module.studio["925418276"].Trails.st[id] = true
-- end

return module