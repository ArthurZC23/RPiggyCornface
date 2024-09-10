local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local PlayerChestS = {}
PlayerChestS.__index = PlayerChestS
PlayerChestS.className = "PlayerChest"
PlayerChestS.TAG_NAME = PlayerChestS.className

function PlayerChestS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
        queue = {},
    }
    setmetatable(self, PlayerChestS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:addTimeQueue()
    self:startChestClock()
    self:handleOpenRequest()

    return self
end

function PlayerChestS:addTimeQueue()
    self._maid:Add(self.playerState:getEvent("Stores", "Chests", "openChest"):Connect(function(state, action)
        table.insert(self.queue, {t1 = action.t1, id = action.id})
        table.sort(self.queue, function(a, b)
            return a.t1 < b.t1
        end)
    end))

    local ChestsData = Data.Chests.Chests
    local chestsState = self.playerState:get("Stores", "Chests")

    for id in pairs(ChestsData.idData) do
        local t1 = chestsState[id]
        if not t1 then continue end
        table.insert(self.queue, {t1 =t1, id = id})
    end
    table.sort(self.queue, function(a, b)
        return a.t1 < b.t1
    end)
end

local Cronos = Mod:find({"Cronos", "Cronos"})
function PlayerChestS:startChestClock(playerState)
    task.spawn(function()
        while self.player.Parent do
            Cronos.wait(1)
            local t = Cronos:getTime()
            local nextChest = self.queue[1]
            if not nextChest then continue end
            local t1 = nextChest.t1
            if t1 <= t then
                self:removeFirstChest(nextChest.id)
            end
        end
    end)
end

function PlayerChestS:removeFirstChest(chestId)
    table.remove(self.queue, 1)
    do
        local action = {
            name = "resetChest",
            id = chestId,
        }
        self.playerState:set("Stores", "Chests", action)
    end
end

function PlayerChestS:verifyOpenConditions(chestId, chestData)
    local reward = chestData.reward
    if reward._type == "Group" then
        local isPlayerInGroup = self.player:GetAttribute("isInGroup")
        if not isPlayerInGroup then return end
    end
    if reward._type == "Gamepass" then
        local gpsState = self.playerState:get(S.Stores, "GamePasses")
        if not gpsState.st[reward.gpId] then return end
    end
    return true
end

function PlayerChestS:isPlayerOnCooldown(chestId)
    local chestsState = self.playerState:get("Stores", "Chests")
    if chestsState[chestId] then return true end
    return false
end

function PlayerChestS:recordChestOpening(chestId, chestData)
    local t0 = Cronos:getTime()
    local t1 = t0 + chestData.cooldown
    local action = {
        name="openChest",
        id=chestId,
        t1 = t1
    }
    self.playerState:set("Stores", "Chests", action)
end

function PlayerChestS:handleOpenRequest()
    self.network:Connect(self.RequestToOpenChestRE.OnServerEvent, function(player, chestId)
        local chestData = Data.Chests.Chests.idData[chestId]
        local canOpen = self:verifyOpenConditions(chestId, chestData)
        if not canOpen then return end

        if self:isPlayerOnCooldown(chestId) then return end

        self:recordChestOpening(chestId, chestData)
        self:giveReward(chestData)
    end)
end

local Rewards = {}
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

function Rewards.giveMoney(self, rData)
    local res = Giver.give(self.playerState, rData.moneyType, rData.baseValue, rData.sourceType, {
        ux = true
    })
    local MoneyData = Data.Money.Money
    NotificationStreamRE:FireClient(self.playerState.player, {
        Text = ("+ %s %s"):format(res.value, MoneyData[rData.moneyType].prettyName),
    })
end

function Rewards.giveLife(self, rData)
    local liveState = self.playerState:get(S.Session, "Lives")
    if liveState.cur >= Data.Map.Map.maxLives then
        NotificationStreamRE:FireClient(self.playerState.player, {
            Text = "Max number of lives!",
        })
        return
    end
    do
        local action = {
            name = "add",
            value = rData.value,
            purchased = true,
            ux = true,
        }
        self.playerState:set(S.Session, "Lives", action)
    end
    NotificationStreamRE:FireClient(self.playerState.player, {
        Text = ("+ %s %s"):format(rData.value, "Life"),
    })
end

function PlayerChestS:giveReward(chestData)
    for _, rData in ipairs(chestData.rewards) do
        Rewards[rData.handler](self, rData)
    end
end

function PlayerChestS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"RequestToOpenChest"},
        functions = {},
    }))
end

function PlayerChestS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 0.5},
    })
end

function PlayerChestS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", self.player}
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerChestS:Destroy()
    self._maid:Destroy()
end

return PlayerChestS