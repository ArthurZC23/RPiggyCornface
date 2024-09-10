local RunService = game:GetService("RunService")

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local TimeUnits = require(Data.Date.TimeUnits)
local Money = require(Data.Money.Money)
local ServerTypesData = require(Data.Game.ServerTypes)
local GpData = require(Data.GamePasses.GamePasses)

local ONE_MINUTE = 60

local function getCooldown(hours)
    -- local envs = {
    --     [ServerTypesData.sTypes.StudioNotPublished] = true,
    --     [ServerTypesData.sTypes.StudioPublishedPrivate] = true,
    --     [ServerTypesData.sTypes.StudioPublishedTest] = true,
    --     [ServerTypesData.sTypes.LivePrivate] = true,
    --     [ServerTypesData.sTypes.LiveTest] = true,
    -- }
    -- if envs[ServerTypesData.ServerType] then
    --     return 120
    -- end

    return hours * TimeUnits.hour
end

local module = {}

module.idData = {
    ["1"] = {
        name = "DailyReward",
        prettyName = {
            Text="Extra Life",
            TextColor3 = Color3.fromRGB(255, 255, 0),
        },
        cooldown = getCooldown(12),
        -- rewardColor = Money[S.Money_1].color,
        rewardColor = Color3.fromRGB(255, 255, 0),
        showRewards = false,
        reward = {
            _type = "Group",
        },
        rewards = {
            {
                -- thumbnail = Money[S.Money_1].thumbnail,
                handler = "giveLife",
                value = 1,
            },
            -- {
            --     thumbnail = Money[S.Money_1].thumbnail,
            --     handler = "giveMoney",
            --     moneyType = S.Money_1,
            --     baseValue = 15,
            --     sourceType = S.Chest,
            -- },
        }
    },
    -- ["2"] = {
    --     name = "VipReward",
    --     prettyName = {
    --         Text="👑 Vip Rewards",
    --         TextColor3 = Color3.fromRGB(255, 255, 0),
    --     },
    --     cooldown = getCooldown(12),
    --     rewardColor = Money[S.Money_1].color,
    --     showRewards = false,
    --     reward = {
    --         _type = "Gamepass",
    --         gpId = GpData.nameToData[S.VipGp].id,
    --     },
    --     rewards = {
    --         {
    --             thumbnail = Money[S.Points].thumbnail,
    --             handler = "giveMoney",
    --             moneyType = S.Points,
    --             baseValue = 500,
    --             sourceType = S.Chest,
    --         },
    --         {
    --             thumbnail = Money[S.Money_1].thumbnail,
    --             handler = "giveMoney",
    --             moneyType = S.Money_1,
    --             baseValue = 2,
    --             sourceType = S.Chest,
    --         },
    --     }
    -- }
}


return module