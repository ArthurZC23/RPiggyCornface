local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})
local TableUtils = Mod:find({"Table", "Utils"})

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {}

module.names = {
    [S.UnitMultiplier] = S.UnitMultiplier,
    -- [S.Friends] = S.Friends,
    -- [S.Idle] = S.Idle,
    -- [S.x2PointsGp] = S.x2PointsGp,
    [S.x2Money_1Gp] = S.x2Money_1Gp,
    -- [S.Rebirth] = S.Rebirth,
    -- [S.PremiumMembership] = S.PremiumMembership,
}
module.names = Mts.makeEnum("Multipliers", module.names)

-- source cannot be empty. Use Unit multiplier to fix it.
module.sourceToMultiplier = {
    [S.Money_1] = {
        Proto = {
            S.UnitMultiplier,
        },
        [S.Chest] = {},
        [S.Money_1Packs] = {},
        -- [S.SocialRewardsCode] = {},
        -- [S.TimeReward] = {}, -- Time gifts
        [S.MapCoin] = {
            S.x2Money_1Gp,
        },
        [S.FinishGame] = {
            S.x2Money_1Gp,
        },
        [S.SpinWheel] = {},
    },
    [S.Points] = {
        Proto = {
            S.UnitMultiplier,
        },
        -- [S.Idle] = {
        --     S.Friends,
        --     S.x2PointsGp,
        --     S.Rebirth,
        --     S.PremiumMembership,
        -- },
        -- [S.Chest] = {},
        -- [S.PointsPacks] = {},
        -- [S.SocialRewardsCode] = {},
        -- [S.TimeReward] = {},
    },
    [S.MoneyMonster] = {
        Proto = {
            S.UnitMultiplier,
        },
        [S.MoneyMonsterPacks] = {},
        [S.FinishGame] = {},
        [S.SpinWheel] = {},
    },
}

for _, sourceTypes in pairs(module.sourceToMultiplier) do
    local proto = sourceTypes.Proto
    if proto then
        for sourceName, multiplier in pairs(sourceTypes) do
            if sourceName == "Proto" then continue end
            sourceTypes[sourceName] = TableUtils.concatArrays(multiplier, proto)
        end
    end
end

--TableUtils.print(module.sourceToMultiplier)

return module