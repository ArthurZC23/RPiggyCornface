local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local ConversorsData = Data.Hamilton.Conversors
local S = Data.Strings.Strings
local UpgradesUtils = require(ComposedKey.getAsync(ReplicatedStorage, {"Upgrades", "Shared", "UpgradesUtils"}))

local module = {}

module.exchanges = {}

module.exchanges[S.SellingStation] = function(playerState, sinkQty)
    local baseExchange = ConversorsData.conversors[S.SellingStation][S.BaseExchange]
    local UpgState = playerState:get(S.Stores, "Upgrades")
    local upgId = "2"
    local upgState = UpgState.upgrades[upgId]
    local currentUpg = upgState.current
    local exchange = baseExchange * UpgradesUtils.computeTotalMultiplier(currentUpg)
    return math.ceil(exchange * sinkQty)
end

return module