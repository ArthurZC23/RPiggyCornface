local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local MoneyLimit = Data.Money.MoneyLimit
local TableUtils = Mod:find({"Table", "Utils"})

local module = {}

local function respectUpperLimit(playerState, value, moneyType)
    local current = playerState:get(S.Stores, moneyType).current
    local newCurrent = current + value
    if newCurrent > MoneyLimit[moneyType] then
        local diff = newCurrent - MoneyLimit[moneyType]
        value -= diff
    end
    return value
end

function module.give(playerState, moneyType, baseValue, sourceType, actionKeys)
    local value = Calculators.calculate(playerState, moneyType, baseValue, sourceType)
    value = respectUpperLimit(playerState, value, moneyType)

    actionKeys = actionKeys or {}
    do
        local action = {
            name = "Increment",
            value = value,
            source = sourceType,
        }
        TableUtils.complementRestrained(action, actionKeys)
        playerState:set(S.Stores, moneyType, action)
    end
    local res = {}
    res.value = value
    return res
end

return module