local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {
    ["1873872904"] = {
        name = "Plus1Life",
        handler = "PurchaseLife",
        value = 1,
        type_ = "LifePurchase",
    },
    ["1873873313"] = {
        name = "ContinuePlus1Life",
        handler = "PurchaseLife",
        value = 1,
        type_ = "LifePurchase",
    },
}

local money_1Data = {
    ["1"] = {
        price = 49,
        baseValue = 50,
        devProductId = "1888470122",
    },
    ["2"] = {
        price = 152,
        baseValue = 160,
        devProductId = "1888470294",
    },
    ["3"] = {
        price = 487,
        baseValue = 550,
        devProductId = "1888470511",
    },
    ["4"] = {
        price = 985,
        baseValue = 1250,
        devProductId = "1888470650",
    },
    ["5"] = {
        price = 3925,
        baseValue = 6000,
        devProductId = "1888470783",
    },
}

for moneyPackId, data in pairs(money_1Data) do
    module[data.devProductId] = {
        name = ("Money_1_Pack%s"):format(moneyPackId),
        handler = "PurchaseMoney_1",
        baseValue = data.baseValue,
        type_ = "MoneyPurchase",
        moneyType = S.Money_1,
        price = data.price,
        sourceType = S.Money_1Packs,
    }
end

local moneyMonsterData = {
    ["1"] = {
        price = 99,
        baseValue = 1,
        devProductId = "1886021777",
    },
    ["2"] = {
        price = 467,
        baseValue = 5,
        devProductId = "1886021919",
    },
    ["3"] = {
        price = 876,
        baseValue = 10,
        devProductId = "1886022084",
    },
}

for moneyPackId, data in pairs(moneyMonsterData) do
    module[data.devProductId] = {
        name = ("MoneyMonsterPack%s"):format(moneyPackId),
        handler = "PurchaseMoneyMonster",
        baseValue = data.baseValue,
        type_ = "MoneyPurchase",
        moneyType = S.MoneyMonster,
        price = data.price,
        sourceType = S.MoneyMonsterPacks,
    }
end

local spinWData = {
    ["SpinWheel_1FirstOfDay"] = {
        -- first of the day
        spinWId = "1",
        value = 1,
        devProductId = "1894713625",
    },
    ["SpinWheel_1Pack1"] = {
        spinWId = "1",
        value = 1,
        devProductId = "1894713107",
    },
    ["SpinWheel_1Pack2"] = {
        spinWId = "1",
        value = 5,
        devProductId = "1894713320",
    },
    ["SpinWheel_1Pack3"] = {
        spinWId = "1",
        value = 10,
        devProductId = "1894713458",
    },
}

for name, data in pairs(spinWData) do
    data.handler = "PurchaseWheelSpins"
    module[data.devProductId] = data
    data.type_ = "SpinWheel"
end

return module