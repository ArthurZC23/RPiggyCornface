local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Topics = Data.CrossServerMessaging.Topics
local Promise = Mod:find({"Promise", "Promise"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local PlayersKickedFromServer = Data.Players.Bans.PlayersKickedFromServer

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local DataStoreService = require(ServerStorage.DataStoreService)
local PlayersDS = DataStoreService:GetDataStore("DATA")

return function (context, userIdStr, reason, banTimeInDays)
    Promise.try(function()
        if banTimeInDays == 0 then banTimeInDays = math.huge end
        if not banTimeInDays then banTimeInDays = math.huge end

        local banTime = 24 * 60 * 60 * banTimeInDays

        -- print(userIdStr, typeof(userIdStr))
        local banData = {
            r = reason or "default",
            ts = Cronos:getTime() + banTime,
            _r = "" -- private reason
        }
        local userId = tonumber(userIdStr)
        local player = Players:GetPlayerByUserId(userId)
        if player then
            -- print("BanServer1")
            local playerState = binderPlayerState:getObj(player)
            if playerState then
                local action = {
                    name = "ban",
                    data = banData
                }
                playerState:set(S.Stores, "Ban", action)
            end
            player:Kick("You are banned from the game.")
            PlayersKickedFromServer[player.UserId] = player.Name
        else
            -- print("BanServer2")
            PlayersDS:UpdateAsync(userIdStr, function(playerState)
                if not playerState then return end
                playerState.Ban = banData
                return playerState
            end)
            MessagingService:PublishAsync(Topics.topics.KICK.name, {
                userId = userId,
                banData = banData,
            })
        end
    end)
    :catchAndPrint()
	return true
end