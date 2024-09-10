local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local TableUtils = Mod:find({"Table", "Utils"})

local function setAttributes()

end
setAttributes()

local PlayerWorldManagerS = {}
PlayerWorldManagerS.__index = PlayerWorldManagerS
PlayerWorldManagerS.className = "PlayerWorldManager"
PlayerWorldManagerS.TAG_NAME = PlayerWorldManagerS.className

function PlayerWorldManagerS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerWorldManagerS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleChangeWorld()
    self:handleUnlockWorlds()
    self:handleWorldChange()
    self:handleBadgeAward()

    return self
end

function PlayerWorldManagerS:handleChangeWorld()
    self.network:Connect(self.ChangeWorldRE.OnServerEvent, function(player, worldId)
        local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = player})
        if not playerState then return end
        local char = player.Character
        if not (char and char.Parent) then return end

        local worldData = Data.Worlds.Worlds.idData[worldId]
        local worldsState = playerState:get(S.Stores, "Worlds")
        if worldsState.open[worldId] then
            do
                local action = {
                    name = "setCurrentWorld",
                    value = worldId
                }
                playerState:set(S.Session, "Worlds", action)
            end
        elseif worldData.price.notEnoughFundsDevProduct then
            local TryDeveloperPurchaseBE = ServerStorage.Bindables.Events.TryDeveloperPurchase
            TryDeveloperPurchaseBE:Fire(player, worldData.price.notEnoughFundsDevProduct)
        end
    end)
end

function PlayerWorldManagerS:handleWorldChange()
    local function update(state)
        local worldId = state.current
        local World = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace, refName=("World%s"):format(worldId)})
        local MapTeleportTargets = SharedSherlock:find({"EzRef", "Get"}, {inst=World, refName=("MapTeleportTargets")})
        local char = self.player.Character
        if not (char and char.Parent) then return end
        local CharTeleportSE = SharedSherlock:find({"Bindable", "async"}, {root = char, signal = "CharTeleport"})
        CharTeleportSE:Fire({
            Targets = MapTeleportTargets.Model:GetChildren()
        })
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "Worlds", "setCurrentWorld"):Connect(update))
    local state = self.playerState:get(S.Session, "Worlds")
    update(state)
end

local Badges = Data.Badges.Badges
function PlayerWorldManagerS:handleBadgeAward()
    local function update(worldState)
        for worldId in pairs(Data.Worlds.Worlds.idData) do
            if worldState.open[worldId] then
                local badgeId = Badges.nameToId[("World%s"):format(worldId)]
                local AwardBadgeSE = SharedSherlock:find({"Bindable", "sync"}, {root = self.player, signal = "AwardBadge"})
                if badgeId then
                    AwardBadgeSE:Fire(badgeId)
                end
            end
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Worlds", "addWorld"):Connect(update))
    local state = self.playerState:get(S.Stores, "Worlds")
    update(state)
end

function PlayerWorldManagerS:handleUnlockWorlds()
    local function update(money_1State)
        local worldState = self.playerState:get(S.Stores, "Worlds")
        local currentMoney = money_1State.current
        for worldId, worldData in pairs(Data.Worlds.Worlds.idData) do
            if worldState.open[worldId] then continue end
            if currentMoney < worldData.price.value then continue end
            do
                local action = {
                    name = "addWorld",
                    id = worldId,
                    ux = true,
                }
                if worldData.price.value == 0 then
                    action.ux = nil
                end
                self.playerState:set(S.Stores, "Worlds", action)
            end
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Money_1", "Increment"):Connect(update))
    local state = self.playerState:get(S.Stores, "Money_1")
    update(state)
end

function PlayerWorldManagerS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"ChangeWorld"},
        functions = {},
    }))
end

function PlayerWorldManagerS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 0.1},
    })
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerWorldManagerS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerWorldManagerS:Destroy()
    self._maid:Destroy()
end

return PlayerWorldManagerS