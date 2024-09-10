local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local binderPlayerFriends = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerFriends"})

local module = {}

function module.playerAndFriends(playerState, remote, ...)
    local player = playerState.player
    remote:FireClient(player, ...)
    module.friends(playerState, remote, ...)
end

function module.friends(playerState, remote, ...)
    local friendsState = playerState:get(S.Session, "Friends")
    for userId in pairs(friendsState.friends) do
        local player = Players:GetPlayerByUserId(userId)
        if player then
            remote:FireClient(player, ...)
        end
    end
end

function module.others(player, remote, ...)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        remote:FireClient(...)
    end
end

return module