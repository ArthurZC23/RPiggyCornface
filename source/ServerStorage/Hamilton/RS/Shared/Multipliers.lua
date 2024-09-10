local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})
local Data = Mod:find({"Data", "Data"})
local Multipliers = Data.Hamilton.Multipliers

local module = {}

function module.getTotalMultiplier(moneyType, sourceType, playerState)
    local allMultipliers = playerState:get("Session", "Multipliers")
    local multipliers = Multipliers.sourceToMultiplier[moneyType][sourceType]
    local multipliersValues = Functional.map(multipliers, function(v)
        return allMultipliers[v]
    end)
    return Functional.reduce(
        multipliersValues,
        function (acc, v) return acc * v end
    )
end

return module