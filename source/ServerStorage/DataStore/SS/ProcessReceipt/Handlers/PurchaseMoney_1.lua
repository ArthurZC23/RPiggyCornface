local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})

local module = {}

function module.handler(_, _, playerState, productData)
    local baseValue = productData.baseValue
    local typeEarned = S.Money_1
    local value = Calculators.calculate(playerState, typeEarned, baseValue, S.Money_1Packs)

    do
        local action = {
            name="Increment",
            value=value,
            ux = true,
        }
        playerState:set(S.Stores, "Money_1", action)
    end
end

return module