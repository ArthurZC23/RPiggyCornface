local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local FriendsData = Data.Friends.Friends
local Promise = Mod:find({"Promise", "Promise"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local FastSpawn = Mod:find({"FastSpawn"})

local ThePlayerExitSE = SharedSherlock:find({"Bindable", "async"}, {root=ServerStorage, signal="ThePlayerExit"})
local ThePlayerReadySE = SharedSherlock:find({"Bindable", "async"}, {root=ServerStorage, signal="ThePlayerReady"})

local PlayerFriendsS = {}
PlayerFriendsS.__index = PlayerFriendsS
PlayerFriendsS.className = "PlayerFriends"
PlayerFriendsS.TAG_NAME = PlayerFriendsS.className

function PlayerFriendsS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
        friends = {},
    }
    setmetatable(self, PlayerFriendsS)

    if not self:getFields() then return end
    self:createRemotes()
    self:handleFriendsInGame()

    return self
end

function PlayerFriendsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"RequestToAddFriend", "RequestToRemoveFriend",},
        functions = {},
    }))
end

function PlayerFriendsS:handleFriendsInGame()
    local function onReady(otherPlayer)
        self._maid:Add2(Promise.try(function()
            local isFriend = self.player:IsFriendsWith(otherPlayer.UserId)
            return isFriend
        end)
        :andThen(function(isFriend)
            local friendType
            if isFriend then
                friendType = FriendsData.friendType.Friend
            else
                friendType = FriendsData.friendType.NotFriend
            end
            if RunService:IsStudio() and Data.Studio.Studio.friends.allFriends then
                -- print(("Set %s as friend of %s  Studio"):format(otherPlayer.Name, self.player.Name))
                friendType = FriendsData.friendType.Friend
            end
            -- print("Set SetInGameFriendType.", self.player, otherPlayer)
            local action = {
                name="SetInGameFriendType",
                userId=otherPlayer.UserId,
                friendType=friendType,
            }
            self.playerState:set(S.Session, "Friends", action)
        end)
        :catch(function (err)
            -- print("catch SetInGameFriendType. friendType Unknown", self.player, otherPlayer)
            local friendType = FriendsData.friendType.Unknown
            local action = {
                name="SetInGameFriendType",
                userId=otherPlayer.UserId,
                friendType=friendType,
            }
            self.playerState:set(S.Session, "Friends", action)
        end))
    end

    local function onExit(otherPlayer)
        --print("ON EXIT")
        local action = {
            name="RemoveInGameFriend",
            userId=otherPlayer.UserId,
        }
        self.playerState:set(S.Session, "Friends", action)
    end

    local function onUnfriend(_, otherPlayer)
        local friendType = FriendsData.friendType.NotFriend
        local action = {
            name="SetInGameFriendType",
            userId=otherPlayer.UserId,
            friendType=friendType,
        }
        self.playerState:set(S.Session, "Friends", action)
    end

    self._maid:Add(ThePlayerExitSE:Connect(function(otherPlayer)
        if self.player == otherPlayer then return end
        onExit(otherPlayer)
    end))

    self._maid:Add(ThePlayerReadySE:Connect(function(otherPlayer)
        if self.player == otherPlayer then return end
        --print("onReady 1")
        onReady(otherPlayer)
    end))

    self.RequestToRemoveFriendRE.OnServerEvent:Connect(onUnfriend)

    self.RequestToAddFriendRE.OnServerEvent:Connect(function(player, otherPlayer)
        --print("onReady 2")
        onReady(otherPlayer)
    end)

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if self.player == otherPlayer then continue end
        --print("onReady 3")
        FastSpawn(function()
            onReady(otherPlayer)
        end)
    end
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerFriendsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerFriendsS:Destroy()
    self._maid:Destroy()
end

return PlayerFriendsS