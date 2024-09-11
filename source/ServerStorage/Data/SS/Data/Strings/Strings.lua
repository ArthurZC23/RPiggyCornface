local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local stringArrays = {
    scoreTime = {
        "allTime",
    },
    commonArray = {
        "SpinWheel",
        "Trails",
        "MapCoin",
        "FinishGame",
        "MonsterSkins",
        "MapReward",
        "Gameplay",
        "Friends",
        "GamePasses",
        "PremiumMembership",
        "PurchaseHistory",
        "SocialRewardsCode",
        "UnitMultiplier",
        "Rebirth",
        "CoreLoop",
    },
    stateArray = {
        "Stores",
        "Session",
        "LocalSession",
    },
    moneyArray = {
        "MoneyMonster",
        "MoneyMonsterPacks",

        "Robux",

        "PointsRate",
        "Points",
        "PointsPacks",
        "Money_1",
        "Money_1Packs",
        "Money_2",
        "Money_2_Packs",
        "MoneyH",
        "MoneyH_Packs",
        "TimeReward",

        "AutoSell",

        "Sink",
        "Source",
        "BaseExchange",

        "Chest",

        "TimePeriod",

        "Cases",

        "Donation",

        "Idle",
    },
    boosts = {
        "SpeedBoost",
        "NoDamageBoost",
        "GhostBoost",
        "JumpBoost",
    },
    gpsArray = {
        "MetalDipPack",
        "x2Money_1Gp",
        "VipGp",
        "SpiderPackGp",
        "RainbowMonsterSkin",
        "SpeedGp",
    },
    scores = {
        "FinishChapter",
        "FinishChapter1",
        "TimePlayed",
        "Kills",
    },
    rarity = {
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Godly",
    },
    -- These are inner teams used by code to add binders and guis.
    teams = {
        "Lobby",
        "MatchHuman",
        "MatchMonster",
    },
}

local module = {}

for _, strings in pairs(stringArrays) do
    for _, s in ipairs(strings) do
        module[s] = s
    end
end

module = Mts.makeEnum("Strings", module)

return module