local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})
local Cronos = Mod:find({"Cronos", "Cronos"})

local Data = script:FindFirstAncestor("Data")
local ScoresData = require(Data.Scores.Scores)
local SpinWheelData = require(Data.SpinWheel.SpinWheel)

local module = {
    schemaVersion = 1
}

module.names = {
    Boosts = "Boosts",
    SpinWheels = "SpinWheels",
    Chests = "Chests",
    Money_1 = "Money_1",
    -- MoneyMonster = "MoneyMonster",
    MonsterSkins = "MonsterSkins",
    -- Trails = "Trails",
    -----------
    Ban = "Ban",
    Badges = "Badges",
    Datetime = "Datetime", -- Protected
    DevPurchases = "DevPurchases",
    GamePasses = "GamePasses",
    ICoins = "ICoins", -- Internal coins for dev purchases.
    RobuxStats = "RobuxStats",
    Scores = "Scores",
    SocialRewards = "SocialRewards",
    Schema = "Schema",
    Server = "Server", -- Protected
    SinglePurchases = "SinglePurchases",
    TestMoney = "TestMoney",
    Time = "Time",
    Settings = "Settings",
}
module.names = Mts.makeEnum("DsbNames", module.names)

module.default = {
    Boosts = {
        st = {},
    },
    SpinWheels = {
        st = {},
    },
    Chests = {},
    Money_1 = {
        current = 0,
    },
    -- MoneyMonster = {
    --     current = 0,
    -- },
    MonsterSkins = {
        eq = "1",
        st = {
            ["1"] = {},
        }
    },
    -- Trails = {
    --     eq = "1",
    --     st = {
    --        ["1"] = true,
    --     },
    -- },
    -----------------------
    Ban = {

    },
    Badges = {},
    Datetime = {ls=DateTime.fromUnixTimestamp(Cronos:getTime()):ToIsoDate()}, --lastSave
    DevPurchases = {
        newestIdx = 1,
        cache = {}
    },
    GamePasses = {
        st = {},
    },
    ICoins = {

    },
    RobuxStats = {
        total = 0,
        totalGp = 0,
        totalDevP = 0,
    },
    Scores = {},
    Schema = {
        ver = module.schemaVersion,
        cts = {},
    },
    Server = {
        ver="0.0.0", -- Version
        lockId = game.JobId,
        lockTimeout = nil,
        -- Automatic set
        placeVersion = {
            current =  nil,
            previous = nil,
        },
    },
    SinglePurchases = {},
    SocialRewards = {
        codes = {},
    },
    TestMoney = {
        current=0
    },
    Time = {
        -- Keep track of duration limited events, gamePasses and etc.
    },
    Settings = {
        Music = true,
    },
}

module.default = Mts.makeEnum("DsbDefaultValues", module.default)

for scoreType in pairs(ScoresData.scoreTypes) do
    for timeType in pairs(ScoresData.timeTypes) do
        module.default.Scores[scoreType] = {}
        module.default.Scores[scoreType][timeType] = 0
    end
end

for id in pairs(SpinWheelData.idData) do
    module.default.SpinWheels.st[id] = {
        spins = 0,
        tSpinsBeforeT1 = 0, -- total Spins Before t1
        t1 = nil,
    }
end

return module