local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GameData = Data.Game.Game
local PermaBan = Data.Players.Bans.PermaBan
local GroupRoles = Data.Players.Roles.GroupRoles.GroupRoles
local Promise = Mod:find({"Promise", "Promise"})
local ServerTypes = Data.Game.ServerTypes
local Queue = Mod:find({"DataStructures", "Queue"})

local PlayerCredentials = {}
PlayerCredentials.__index = PlayerCredentials
PlayerCredentials.className = "PlayerCredentials"
PlayerCredentials.TAG_NAME = PlayerCredentials.className

function PlayerCredentials.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
        kickedFromThisServerSet = {},
        kickedFromThisServerQueue = Queue.new(
            {},
            {
                maxSize=100,
                fullQueueHandler=Queue.FullQueueHandlers.ReplaceOld,
            }
        ),
        kickedFromThisServerQueueSize = 0,
    }
    setmetatable(self, PlayerCredentials)
    self.areCredentialsValid = self:arePlayerCredentialsValid(player)

    return self
end

function PlayerCredentials:arePlayerCredentialsValid(player)
    return Promise.new(function(resolve, reject)
        if self:isPermaBan(player) == true then
            local MESSAGE = ("You are banned from %s games."):format(GameData.developer.name)
            return reject(MESSAGE)
        end
        if self:wasKickedFromThisSever(player) == true then
            local MESSAGE = "You were kicked from this server. Join another server."
            return reject(MESSAGE)
        end
        local isLivePrivateServer = (ServerTypes.ServerType == ServerTypes.sTypes.LivePrivate)
        if isLivePrivateServer then
            if not self:doesPlayerHasPrivateServerCredentials(player) then
                local MESSAGE = "Private server is not avaiable!"
                return reject(MESSAGE)
            end
        end
        local isLiveTestServer = (ServerTypes.ServerType == ServerTypes.sTypes.LiveTest)
        if isLiveTestServer then
            if not self:doesPlayerHasTestServerCredentials(player) then
                local MESSAGE = "Test server only for authorized users!"
                return reject(MESSAGE)
            end
        end
        return resolve()
    end)
end

function PlayerCredentials:isPermaBan(player)
    if PermaBan[player.UserId] then
        return true
    end
end

function PlayerCredentials:wasKickedFromThisSever(player)
    if self.kickedFromThisServerSet[player.UserId] then
        return true
    end
end

function PlayerCredentials:doesPlayerHasTestServerCredentials(player)
    local ok, role =  pcall(function()
        return self.player:GetRoleInGroup(GameData.developer.id)
    end)
    if not ok then return false end
    local permissions = GroupRoles.roles[role].permissions
    if not permissions.accessTestServer then
        return false
    end
    return true
end

function PlayerCredentials:doesPlayerHasPrivateServerCredentials(player)
    local whitelist = {
        ["925418276"] = true,
        ["1350478020"] = true,
        ["1700355376"] = true,
    }
    if not whitelist[tostring(player.UserId)] then return false end
    return true
end

function PlayerCredentials:Destroy()
    self._maid:Destroy()
end

return PlayerCredentials