local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GpData = Data.GamePasses.GamePasses

local function handler(playerState)
    local maid = Maid.new()
    playerState.player:SetAttribute("ChatTagText", "VIP")

    local trailState = playerState:get(S.Stores, "Trails")
    for trailId, trailData in pairs(Data.Trails.Trails.idData) do
        local shopData = trailData.rewards.shop
        if shopData._type ~= "Gamepass" then continue end
        if shopData.gpId ~= GpData.nameToData[S.VipGp].id then continue end
        if trailState.st[trailId] then continue end
        do
            local action = {
                name = "add",
                id = trailId,
            }
            playerState:set(S.Stores, "Trails", action)
        end
    end

    return maid
end

return handler