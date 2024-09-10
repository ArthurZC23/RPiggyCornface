local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local SuperUsers = Data.Players.Roles.HiddenRoles.HiddenRoles.SuperUsers
local S = Data.Strings.Strings
local RootF = script.Parent
local GamePassesHandlers = require(RootF.GamePassesHandlers)
local Utils = require(RootF.Utils)

local PlayerGamePassesS = {}
PlayerGamePassesS.__index = PlayerGamePassesS
PlayerGamePassesS.className = "PlayerGamePasses"
PlayerGamePassesS.TAG_NAME = PlayerGamePassesS.className

function PlayerGamePassesS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerGamePassesS)
    if not self:getFields() then return end

    self:handleGps()
    self:applyGamePasses()
    return self
end

function PlayerGamePassesS:handleGps()
    local function update(gpId)
        local gpData = Data.GamePasses.GamePasses.idToData[gpId]
        if not gpData then return end
        local gpName = gpData["name"]
        if GamePassesHandlers[gpName] then
            self._maid:Add(GamePassesHandlers[gpName](self.playerState, self))
        end
    end
    self._maid:Add2(self.playerState:getEvent(S.Stores, "GamePasses", "enableGamepass"):Connect(function(state, action)
        update(action.id)
    end))
end

function PlayerGamePassesS:addGamePassToPlayer(gpId)
    local gpState = self.playerState:get(S.Stores, "GamePasses")
    if not gpState.st[gpId] then
        local action = {
            name="addGamePass",
            id=tostring(gpId)
        }
        self.playerState:set(S.Stores, "GamePasses", action)
    end
    do
        local action = {
            name="enableGamepass",
            id=tostring(gpId)
        }
        self.playerState:set(S.Stores, "GamePasses", action)
    end
end

function PlayerGamePassesS:removeGamePassFromPlayer(gpId)
    -- Keep the rewards
    -- This way player cannot delete gp and buy again
    local gpState = self.playerState:get(S.Stores, "GamePasses")
    if gpState.st[gpId] then
        local action = {
            name="disableGamepass",
            id=tostring(gpId)
        }
        self.playerState:set(S.Stores, "GamePasses", action)
    end
end

function PlayerGamePassesS:applyGamePasses()
    for _, gpData in pairs(Data.GamePasses.GamePasses.data) do
        self._maid:Add2(Utils.doesPlayerHasGamePass(self.playerState, gpData.id)
        :andThen(function(hasPass)
            if hasPass then
                self:addGamePassToPlayer(gpData.id)
            else
                self:removeGamePassFromPlayer(gpData.id)
            end
        end)
        :catch(function (err) warn(tostring(err)) end))
    end
end

function PlayerGamePassesS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.backpack = self.player:FindFirstChild("Backpack")
            if not self.backpack then return end

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

function PlayerGamePassesS:Destroy()
    self._maid:Destroy()
end

return PlayerGamePassesS