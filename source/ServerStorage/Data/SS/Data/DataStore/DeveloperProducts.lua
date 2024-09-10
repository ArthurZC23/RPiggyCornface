local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)

local module = {
    -- ["1873872904"] = {
    --     name = "Plus1Life",
    --     handler = "PurchaseLife",
    --     value = 1,
    --     type_ = "LifePurchase",
    -- },

}

-- local money_1Data = {
--     ["1"] = {
--         price = 49,
--         baseValue = 50,
--         devProductId = "1888470122",
--     },
--     ["2"] = {
--         price = 152,
--         baseValue = 160,
--         devProductId = "1888470294",
--     },
--     ["3"] = {
--         price = 487,
--         baseValue = 550,
--         devProductId = "1888470511",
--     },
--     ["4"] = {
--         price = 985,
--         baseValue = 1250,
--         devProductId = "1888470650",
--     },
--     ["5"] = {
--         price = 3925,
--         baseValue = 6000,
--         devProductId = "1888470783",
--     },
-- }

-- for moneyPackId, data in pairs(money_1Data) do
--     module[data.devProductId] = {
--         name = ("Money_1_Pack%s"):format(moneyPackId),
--         handler = "PurchaseMoney_1",
--         baseValue = data.baseValue,
--         type_ = "MoneyPurchase",
--         moneyType = S.Money_1,
--         price = data.price,
--         sourceType = S.Money_1Packs,
--     }
-- end

return module