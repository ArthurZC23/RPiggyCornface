local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TimeUnits = Data.Date.TimeUnits

local Giver = Mod:find({"Hamilton", "Giver", "Giver"})

local module = {}

function module.code1()
    print("Code 1 redeemed")
end

function module.tik100(playerState)
    local keyId = "1"
    local numKeys = playerState:get(S.Stores, "Keys").k[keyId]
    numKeys += 3
    local action = {
        name = "set",
        keyId = keyId,
        value = numKeys
    }
    playerState:set(S.Stores, "Keys", action)
end

function module.tik500(playerState)
    local keyId = "1"
    local numKeys = playerState:get(S.Stores, "Keys").k[keyId]
    numKeys += 3
    local action = {
        name = "set",
        keyId = keyId,
        value = numKeys
    }
    playerState:set(S.Stores, "Keys", action)
end

function module.slayer1k(playerState)
    local typeEarned = S.Money_1
    local value = 450
    local sourceType = S.SocialRewardsCode
    Giver.give(playerState, typeEarned, value, sourceType)
end

function module.slayer5k(playerState)
    local typeEarned = S.Money_1
    local value = 450
    local sourceType = S.SocialRewardsCode
    Giver.give(playerState, typeEarned, value, sourceType)
end

return module