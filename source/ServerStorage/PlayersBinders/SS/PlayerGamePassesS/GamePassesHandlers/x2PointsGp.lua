local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings


local function handler(playerState)
    local maid = Maid.new()
    local function update(gpsState)
        local MultipliersData = Data.Hamilton.Multipliers
        local gpData = Data.GamePasses.GamePasses.nameToData[S.x2PointsGp]
        if not gpsState.st[gpData.id] then return end
        local action = {
            name = "updateMultiplier",
            value = 2,
            multiplier = MultipliersData.names[S.x2PointsGp]
        }
        playerState:set("Session", "Multipliers", action)
    end

    maid:Add(playerState:getEvent("Stores", "GamePasses", "addGamePass"):Connect(update))
    update(playerState:get("Stores", "GamePasses"))
    return maid
end

return handler