local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local function setAttributes()

end
setAttributes()

local PlayerTimeRewardS = {}
PlayerTimeRewardS.__index = PlayerTimeRewardS
PlayerTimeRewardS.className = "PlayerTimeReward"
PlayerTimeRewardS.TAG_NAME = PlayerTimeRewardS.className

function PlayerTimeRewardS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
        queue = {},
    }
    setmetatable(self, PlayerTimeRewardS)

    if not self:getFields() then return end
    self:setPlayerNetwork()
    self:createRemotes()
    self:updatePlayerTimeRewardDurations()
    self:addTimeQueue()
    self:startTimer()
    self:handleRequestTimeReward()

    return self
end

function PlayerTimeRewardS:addTimeQueue()
    local PlayerTimeRewardData = Data.TimeRewards.TimeRewards
    local timeRewardState = self.playerState:get("Stores", "TimeRewards")
    local rewardsSt = timeRewardState.st
    for id in pairs(PlayerTimeRewardData.idData) do
        local rewardState = rewardsSt[id]
        if rewardState.p or rewardState.pU then continue end
        local t1 = rewardState.t0 + rewardState.d
        table.insert(self.queue, {t1 = t1, id = id})
    end
    table.sort(self.queue, function(a, b)
        return a.t1 < b.t1
    end)
end

function PlayerTimeRewardS:startTimer()
    task.spawn(function()
        while self.player.Parent do
            Cronos.wait(1)
            local t = Cronos:getTime()
            local nextReward = self.queue[1]
            if not nextReward then continue end
            local t1 = nextReward.t1
            --print((t1 - t), (t1 - t) / 60, (t1 - t) / 3600)
            if t1 <= t then
                local id = nextReward.id
                table.remove(self.queue, 1)
                do
                    local action = {
                        name = "unlockPrize",
                        id = id,
                    }
                    self.playerState:set(S.Stores, "TimeRewards", action)
                end
            end
        end
    end)
end

function PlayerTimeRewardS:handleRequestTimeReward()
    self.network:Connect(self.RequestTimeRewardRE.OnServerEvent, function(player, rewardId)
        local timeRewardState = self.playerState:get("Stores", "TimeRewards")
        local rewardsSt = timeRewardState.st

        if not rewardsSt[rewardId] then return end
        if not rewardsSt[rewardId].pU then return end
        if rewardsSt[rewardId].p then return end

        local rewardData = Data.TimeRewards.TimeRewards.idData[rewardId]
        self:giveReward(rewardId, rewardData)
    end)
end

local Rewards = {}
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
function Rewards.giveMoney(self, rData)
    Giver.give(self.playerState, rData.moneyType, rData.baseValue, rData.sourceType, {
        ux = true
    })
end

function PlayerTimeRewardS:giveReward(rewardId, rewardData)
    do
        local action = {
            name = "givePrize",
            id = rewardId,
        }
        self.playerState:set(S.Stores, "TimeRewards", action)
    end
    local notification = {}
    local MoneyData = Data.Money.Money
    for _, rData in ipairs(rewardData.rewards) do
        Rewards[rData.handler](self, rData)
        table.insert(notification, ("+%s %s"):format(rData.baseValue, MoneyData[rData.moneyType].prettyName))
    end
    notification = table.concat(notification, " ")
    NotificationStreamRE:FireClient(self.player, {
        Text = notification,
    })
end

function PlayerTimeRewardS:resetTimers()
    local PlayerTimeRewardData = Data.TimeRewards.TimeRewards
    for id, data in pairs(PlayerTimeRewardData.idData) do
        local t0 = Cronos:getTime()
        do
            local action = {
                name = "setTimer",
                id = id,
                d = data.duration,
                t0 = t0,
            }
            self.playerState:set(S.Stores, "TimeRewards", action)
        end
    end
end

function PlayerTimeRewardS:continuePreviousSession()
        -- Doens't count while player is offline
    local lastSaveDatetimeIso = self.playerState:get(S.Stores, "Datetime")
    local lastSaveDatetime = DateTime.fromIsoDate(lastSaveDatetimeIso.ls)

    for id, data in pairs(self.playerState:get(S.Stores, "TimeRewards").st) do
        if data.p == true or data.pU == true then continue end

        local consumedTime = (lastSaveDatetime.UnixTimestamp - data.t0)
        local duration = math.max(data.d - consumedTime, 0)
        local t0 = Cronos:getTime()

        local action = {
           name="setTimer",
           id=id,
           d=duration,
           t0=t0
        }

        self.playerState:set(S.Stores, "TimeRewards", action)
    end
end

function PlayerTimeRewardS:updatePlayerTimeRewardDurations()
    -- Doens't count while player is offline
    local lastSaveDatetimeIso = self.playerState:get("Stores", "Datetime")
    local lastSaveDatetime = DateTime.fromIsoDate(lastSaveDatetimeIso.ls)
    local t0 = lastSaveDatetime.UnixTimestamp
    local t1 = Cronos:getTime()
    -- print("Time diff: ", t1 - t0)

    local timeRewardState = self.playerState:get("Stores", "TimeRewards")
    local hasAllPrizes = true
    for _, data in pairs(timeRewardState.st) do
        if data.p ~= true then
            hasAllPrizes = false
            break
        end
    end

    if hasAllPrizes or t1 - t0 > 60 * 2 then
        self:resetTimers()
    else
        self:continuePreviousSession()
    end
end

function PlayerTimeRewardS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"RequestTimeReward"},
        functions = {},
    }))
end

function PlayerTimeRewardS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerTimeRewardS:getFields()
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

function PlayerTimeRewardS:Destroy()
    self._maid:Destroy()
end

return PlayerTimeRewardS