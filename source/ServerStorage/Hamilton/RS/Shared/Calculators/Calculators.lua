local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local MultiplierMath = Mod:find({"Hamilton", "MultiplierMath"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.calculate(playerState, moneyType, base, sourceType)
    local totalMultiplier = MultiplierMath.getTotalMultiplier(
        moneyType,
        sourceType,
        playerState
    )
    return math.ceil(totalMultiplier * base)
end

return module