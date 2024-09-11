local RunService = game:GetService("RunService")
local Data = script:FindFirstAncestor("Data")
local TimeUnits = require(Data.Date.TimeUnits)
local S = require(Data.Strings.Strings)
local BoostsData = require(Data.Boosts.Boosts)
local MoneyData = require(Data.Money.Money)


local module = {}

--[[
    Multiple prizes in the handler.
    Thumbnail and viewName should give an overview of all of them at once.
    This is a flexible schema that allow wheels with different number of prizes. Only need
    the segment image to build the wheel gui.
]]--

module.idData = {
    -- ["1"] = {
    --     freeSpins = 1,
    --     name = "SpinWheel_1",
    --     cooldown = 24 * TimeUnits.hour,
    --     rewards = {
    --         ["1"] = {
    --             thumbnail = "rbxassetid://17113222332",
    --             viewName = ("1 Life"),
    --             handlers = {
    --                 {
    --                     handler = "GiveLife",
    --                     value = 1,
    --                 }
    --             },
    --         },
    --         ["2"] = {
    --             thumbnail = "rbxassetid://17113222332",
    --             viewName = ("2 Life"),
    --             handlers = {
    --                 {
    --                     handler = "GiveLife",
    --                     value = 2,
    --                 }
    --             },
    --         },
    --         ["3"] = {
    --             thumbnail = "rbxassetid://17769791063",
    --             viewName = ("1 %s"):format(MoneyData[S.MoneyMonster].viewNameSingular),
    --             handlers = {
    --                 {
    --                     handler = "GiveMoney",
    --                     moneyType = S.MoneyMonster,
    --                     baseValue = 1,
    --                     sourceType = S.SpinWheel,
    --                 },
    --             },
    --         },
    --         ["4"] = {
    --             thumbnail = BoostsData.nameData[S.GhostBoost].thumbnail,
    --             viewName = ("No damage (3 min)"):format(),
    --             handlers = {
    --                 {
    --                     handler = "GiveBoost",
    --                     id = BoostsData.nameData[S.GhostBoost].id,
    --                     duration = 3 * TimeUnits.minute,
    --                 },
    --             },
    --         },
    --         ["5"] = {
    --             thumbnail = "rbxassetid://17769791063",
    --             viewName = ("2 %s"):format(MoneyData[S.MoneyMonster].viewNameSingular),
    --             handlers = {
    --                 {
    --                     handler = "GiveMoney",
    --                     moneyType = S.MoneyMonster,
    --                     baseValue = 2,
    --                     sourceType = S.SpinWheel,
    --                 },
    --             },
    --         },
    --         ["6"] = {
    --             thumbnail = "rbxassetid://6543591915",
    --             viewName = ("500 %s"):format(MoneyData[S.Money_1].prettyName),
    --             handlers = {
    --                 {
    --                     handler = "GiveMoney",
    --                     moneyType = S.Money_1,
    --                     baseValue = 500,
    --                     sourceType = S.SpinWheel,
    --                 },
    --             },
    --         },
    --         ["7"] = {
    --             thumbnail = "rbxassetid://17769791063",
    --             viewName = ("10 %s"):format(MoneyData[S.MoneyMonster].prettyName),
    --             handlers = {
    --                 {
    --                     handler = "GiveMoney",
    --                     moneyType = "MoneyMonster",
    --                     baseValue = 10,
    --                     sourceType = S.SpinWheel,
    --                 },
    --             },
    --         },
    --         ["8"] = {
    --             isVpf = true,
    --             vpf = {
    --                 CameraAngles = Vector3.new(0, 0, 0),
    --                 CameraPosition = Vector3.new(0.5, 0.5, -7),
    --                 CameraPositionOffset = Vector3.new(0, 2.5, 0),
    --             },
    --             viewName = ("Exclusive Skin"):format(),
    --             assetId = "15",
    --             handlers = {
    --                 {
    --                     handler = "GiveMonsterSkin",
    --                     assetId = "15",
    --                 }
    --             },
    --         },
    --     },
    --     odds = {
    --         ["1"] = (28 - 0.1) * 1e-2,
    --         ["2"] = 23e-2,
    --         ["3"] = 20e-2,
    --         ["4"] = 15e-2,
    --         ["5"] = 8e-2,
    --         ["6"] = 5e-2,
    --         ["7"] = 1e-2,
    --         ["8"] = 0.1e-2,
    --     },
    --     oddsView = {
    --         ["1"] = "28%",
    --         ["2"] = "23%",
    --         ["3"] = "20%",
    --         ["4"] = "15%",
    --         ["5"] = "8%",
    --         ["6"] = "5%",
    --         ["7"] = "1%",
    --         ["8"] = "0.1%",
    --     },
    --     gui = {
    --         tabs = {
    --             ["SpinWheel_1"] = {
    --                 name = "SpinWheel_1",
    --                 guiName = "SpinWheel_1Controller",
    --             },
    --             ["SpinWheel_1Details"] = {
    --                 name = "SpinWheel_1Details",
    --                 guiName = "SpinWheel_1DetailsController",
    --             },
    --             ["SpinWheel_1Odds"] = {
    --                 name = "SpinWheel_1Odds",
    --                 guiName = "SpinWheel_1OddsController",
    --             },
    --         },
    --     },
    -- }
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

if RunService:IsStudio() then
    -- module.idData["1"].cooldown = 9
    -- module.idData["1"].odds = {
    --     ["1"] = 0,
    --     ["2"] = 0,
    --     ["3"] = 0,
    --     ["4"] = 0,
    --     ["5"] = 1,
    --     ["6"] = 0,
    --     ["7"] = 0,
    --     ["8"] = 0,
    -- }
end

return module