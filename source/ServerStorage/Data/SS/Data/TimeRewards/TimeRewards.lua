local RunService = game:GetService("RunService")

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {}

local ONE_MINUTE = 60

module.idData = {
    ["1"] = {
        duration = 3 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Points,
                baseValue = 50,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 1,
        },
    },
    ["2"] = {
        duration = 5 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Points,
                baseValue = 100,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 2,
        },
    },
    ["3"] = {
        duration = 7 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Points,
                baseValue = 250,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 3,
        },
    },
    ["4"] = {
        duration = 15 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Money_1,
                baseValue = 1,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 4,
        },
    },
    ["5"] = {
        duration = 20 * ONE_MINUTE,
        handler = "Reward1",
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Money_1,
                baseValue = 5,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 5,
        },
    },
    ["6"] = {
        duration = 30 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Money_1,
                baseValue = 10,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 6,
        },
    },
    ["7"] = {
        duration = 45 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Money_1,
                baseValue = 25,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 7,
        },
    },
    ["8"] = {
        duration = 60 * ONE_MINUTE,
        rewards = {
            {
                handler = "giveMoney",
                moneyType = S.Money_1,
                baseValue = 50,
                sourceType = S.TimeReward,
            },
        },
        view = {
            LayoutOrder = 8,
        },
    },
}

if RunService:IsStudio() then
    for id, data in pairs(module.idData) do
        data.duration = tonumber(id) * 10
    end
end

return module