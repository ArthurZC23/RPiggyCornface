local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local S = Data.Strings.Strings

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerDefaults = {}
PlayerDefaults.__index = PlayerDefaults
PlayerDefaults.className = "PlayerDefaults"
PlayerDefaults.TAG_NAME = PlayerDefaults.className

function PlayerDefaults.new(player)
    local self = {}
    setmetatable(self, PlayerDefaults)
    self._maid = Maid.new()

    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end
    -- self:addDefaultMoments(playerState)

    return self
end


-- function PlayerDefaults:addDefaultMoments(playerState)
--     local momentsState = playerState:get(S.Stores, "Moments")
--     for momentId, momentData in pairs(MomentsData.moments) do
--         if not momentsState.moments[momentId] then
--             local action = {
--                 name = "setMoment",
--                 momentId = momentId,
--                 value = 0,
--             }
--             playerState:set(S.Stores, "Moments", action)
--         end
--         if not momentsState.tokens[momentId] then
--             local action = {
--                 name = "setToken",
--                 tokenId = momentId,
--                 value = 0,
--             }
--             playerState:set(S.Stores, "Moments", action)
--         end
--     end
-- end

function PlayerDefaults:Destroy()
    self._maid:Destroy()
end

return PlayerDefaults