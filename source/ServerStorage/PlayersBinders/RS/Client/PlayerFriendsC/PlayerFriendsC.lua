local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local PlayerFriendsC = {}
PlayerFriendsC.__index = PlayerFriendsC
PlayerFriendsC.className = "PlayerFriends"
PlayerFriendsC.TAG_NAME = PlayerFriendsC.className

function PlayerFriendsC.new(player)
    if localPlayer ~= player then return end

    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerFriendsC)

    if not self:getFields() then return end

    self:handleFriendsInGame()

    return self
end

function PlayerFriendsC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.RequestToAddFriendRE = ComposedKey.getFirstDescendant(localPlayer, {"Remotes", "Events", "RequestToAddFriend"})
            if not self.RequestToAddFriendRE then return end
            self.RequestToRemoveFriendRE = ComposedKey.getFirstDescendant(localPlayer, {"Remotes", "Events", "RequestToRemoveFriend"})
            if not self.RequestToRemoveFriendRE then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerFriendsC:handleFriendsInGame()
    StarterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(otherPlayer)
        self.RequestToAddFriendRE:FireServer(otherPlayer)
    end)
    StarterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(otherPlayer)
        self.RequestToRemoveFriendRE:FireServer(otherPlayer)
    end)
end

function PlayerFriendsC:Destroy()
    self._maid:Destroy()
end

return PlayerFriendsC