local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module._giveNormalBoost(playerState, boostId, duration)
    local boostsState = playerState:get("Stores", "Boosts")
    local totalDuration
    local t0

    if boostsState.st[boostId] then
        local previousDuration = boostsState.st[boostId]["duration"]
        totalDuration = previousDuration + duration
        t0 = boostsState.st[boostId]["t0"]
    else
        totalDuration = duration
        t0 = Cronos:getTime()
    end

    local action = {
        name="addBoost",
        boostId=boostId,
        duration=totalDuration,
        t0=t0,
    }
    playerState:set("Stores", "Boosts", action)
end


function module.giveBoost(playerState, boostId, duration)
    module._giveNormalBoost(playerState, boostId, duration)
end

return module