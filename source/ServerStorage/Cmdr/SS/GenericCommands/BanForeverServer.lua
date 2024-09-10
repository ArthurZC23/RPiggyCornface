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
local GroupRoles = Data.Players.Roles.GroupRoles.GroupRoles
local Topics = Data.CrossServerMessaging.Topics
local Promise = Mod:find({"Promise", "Promise"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local Policies = Data.Players.Policies.Policies
local PlayersKickedFromServer = Data.Players.Bans.PlayersKickedFromServer
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local binderPlayerGroup = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerGroup"})

local DataStoreService = require(ServerStorage.DataStoreService)
local PlayersDS = DataStoreService:GetDataStore("DATA")

return function (context, player, duration)
    Promise.try(function()

        local executor = context.Executor
        local targetPlayerState = binderPlayerState:getObj(player)

        if not targetPlayerState then
            warn("Target PlayerState  binder missing", targetPlayerState)
            return
        end

        local targetRole = targetPlayerState:get(S.Session, "Group").role

        local targetPolicies = GroupRoles.roles[targetRole].policies
        if targetPolicies[Policies.policies.moderator.name] then
            NotificationStreamRE:FireClient(executor, {
                Text = ("Can't ban mod or higher role. Report any misconduct of higher roles on the community server."),
            })
            return
        end

        local banTime = math.huge
        local banData = {
            r = "default",
            ts = banTime,
            _r = "" -- private reason
        }

        local action = {
            name = "ban",
            data = banData
        }
        targetPlayerState:set(S.Stores, "Ban", action)
        player:Kick("You are banned from the game forever.")
    end)
    :catchAndPrint()
	return true
end