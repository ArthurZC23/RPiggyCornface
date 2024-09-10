local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local GameData = Data.Game.Game

local PlayerGroup = {}
PlayerGroup.__index = PlayerGroup
PlayerGroup.className = "PlayerGroup"
PlayerGroup.TAG_NAME = PlayerGroup.className

function PlayerGroup.new(player)
    if not GameData.developer.isGroup then return end

    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerGroup)
    if not self:getFields() then return end
    self:setPlayerGroup()

    return self
end

function PlayerGroup:setPlayerGroup()
    local function _getGroup()
        return Promise.new(function(resolve, reject)
            local ok, group = pcall(function()
                local mockRole = Data.Studio.Studio.group.mockRole[tostring(self.player.UserId)]
                if RunService:IsStudio() and Data.Studio.Studio.group.areFakePlayersInGroup and self.player.UserId < 0 then
                    return true
                elseif RunService:IsStudio() and mockRole == "Guest" then
                    return false
                end
                return self.player:IsInGroup(GameData.developer.id)
            end)
            if ok then
                resolve(group)
            else
                local err = group
                reject(err)
            end
        end)
    end
    Promise.retryWithDelay(_getGroup, 3, 10)
    :andThen(function(isInGroup)
         self.player:SetAttribute("isInGroup", isInGroup)
         self:updateGroupRole()
    end)
end

function PlayerGroup:updateGroupRole()
    local function _getGroupRole()
        return Promise.new(function(resolve, reject)
            local ok, roleInGroup = pcall(function()
                local mockRole = Data.Studio.Studio.group.mockRole[tostring(self.player.UserId)]
                if RunService:IsStudio() and mockRole then
                    print("Mock Role: ", mockRole)
                    return mockRole
                end
                return self.player:GetRoleInGroup(GameData.developer.id)
            end)
            if ok then
                resolve(roleInGroup)
            else
                local err = roleInGroup
                reject(err)
            end
        end)
    end
    Promise.retryWithDelay(_getGroupRole, 3, 10)
    :andThen(function(groupRole)
        self.player:SetAttribute("groupRole", groupRole)
    end)
end

function PlayerGroup:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
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

function PlayerGroup:Destroy()
    self._maid:Destroy()
end

return PlayerGroup