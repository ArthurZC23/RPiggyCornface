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
local Sampler = Mod:find({"Math", "Sampler"})

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local PlayerSpinWheelS = {}
PlayerSpinWheelS.__index = PlayerSpinWheelS
PlayerSpinWheelS.className = "PlayerSpinWheel"
PlayerSpinWheelS.TAG_NAME = PlayerSpinWheelS.className

function PlayerSpinWheelS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
        queue = {},
    }
    setmetatable(self, PlayerSpinWheelS)

    self.rewardSampler = self._maid:Add2(Sampler.new())

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:setFreeSpins()
    self:addTimeQueue()
    self:startClock()
    self:handleOpenRequest()

    return self
end

function PlayerSpinWheelS:setFreeSpins()
    local spinState = self.playerState:get(S.Stores, "SpinWheels")
    for id, data in pairs(Data.SpinWheel.SpinWheel.idData) do
        local stateData = spinState.st[id]
        if stateData.t1 == nil and stateData.spins <= 0 then
            do
                local action = {
                    name = "reset",
                    freeSpins = data.freeSpins,
                    id = id,
                }
                self.playerState:set(S.Stores, "SpinWheels", action)
            end
        end
    end
end

local Functional = Mod:find({"Functional"})
function PlayerSpinWheelS:addTimeQueue()
    local function removeTimerFromQueue(state, action)
        self.queue = Functional.filter(self.queue, function(entry)
            if entry.id == action.id then return false end
        end)
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "SpinWheels", "stopTimer"):Connect(removeTimerFromQueue))

    self._maid:Add(self.playerState:getEvent(S.Stores, "SpinWheels", "startSpinTimer"):Connect(function(state, action)
        table.insert(self.queue, {t1 = action.t1, id = action.id})
        table.sort(self.queue, function(a, b)
            return a.t1 < b.t1
        end)
    end))

    local SpinWheelData = Data.SpinWheel.SpinWheel
    local spinState = self.playerState:get(S.Stores, "SpinWheels")

    for id in pairs(SpinWheelData.idData) do
        local t1 = spinState.st[id].t1
        if not t1 then continue end
        table.insert(self.queue, {t1 = t1, id = id})
    end
    table.sort(self.queue, function(a, b)
        return a.t1 < b.t1
    end)
end

local Cronos = Mod:find({"Cronos", "Cronos"})
local Promise = Mod:find({"Promise", "Promise"})
function PlayerSpinWheelS:startClock()
    self._maid:Add2(Promise.try(function()
        while self.player.Parent do
            Cronos.wait(1)
            local t = Cronos:getTime()
            local firstEntry = self.queue[1]
            if not firstEntry then continue end
            local t1 = firstEntry.t1
            if t1 <= t then
                self:removeFirstEntry(firstEntry.id)
            end
        end
    end))
end

function PlayerSpinWheelS:removeFirstEntry(assetId)
    table.remove(self.queue, 1)
    local data = Data.SpinWheel.SpinWheel.idData[assetId]
    do
        local action = {
            name = "reset",
            id = assetId,
            freeSpins = data.freeSpins,
        }
        self.playerState:set(S.Stores, "SpinWheels", action)
    end
end

function PlayerSpinWheelS:canSpin(spinWData)
    local spinWId = spinWData.id
    local spinWheelState = self.playerState:get(S.Stores, "SpinWheels")
    local spinState = spinWheelState.st[spinWId]
    if spinState.spins <= 0 or spinState.t1 ~= nil then
        NotificationStreamRE:FireClient(self.playerState.player, {
            Text = ("No spins left!"),
        })
        return false
    end
    return true
end

function PlayerSpinWheelS:useSpin(spinWData)
    local spinWId = spinWData.id
    do
        local action = {
            name = "useSpin",
            id = spinWId,
            value = 1,
        }
        self.playerState:set(S.Stores, "SpinWheels", action)
    end

    local spinWheelState = self.playerState:get(S.Stores, "SpinWheels")
    local spinState = spinWheelState.st[spinWId]
    if spinState.spins <= 0 then
        local t0 = Cronos:getTime()
        local t1 = t0 + spinWData.cooldown
        do
            local action = {
                name = "startSpinTimer",
                id = spinWId,
                t1 = t1,
            }
            self.playerState:set(S.Stores, "SpinWheels", action)
        end
    end
end

function PlayerSpinWheelS:handleOpenRequest()
    self.network:Connect(self.RequestSpinWheelRE.OnServerEvent, function(player, spinWId)
        local spinWData = Data.SpinWheel.SpinWheel.idData[spinWId]
        if not self:canSpin(spinWData) then return end
        self:useSpin(spinWData)
        self:giveReward(spinWData)
    end)
end

local Rewards = {}
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
local BoostsUtils = Mod:find({"Boosts", "SS", "Utils"})

function Rewards.GiveBoost(self, rData)
    BoostsUtils.giveBoost(self.playerState, rData.id, rData.duration)
end

function Rewards.GiveLife(self, rData)
    local liveState = self.playerState:get(S.Session, "Lives")
    if liveState.cur >= Data.Map.Map.maxLives then
        return
    end
    do
        local action = {
            name="add",
            value=rData.value,
        }
        self.playerState:set(S.Session, "Lives", action)
    end
end

function Rewards.GiveMoney(self, rData)
    local res = Giver.give(self.playerState, rData.moneyType, rData.baseValue, rData.sourceType, {
        ux = false
    })
    local MoneyData = Data.Money.Money
    NotificationStreamRE:FireClient(self.playerState.player, {
        Text = ("+ %s %s"):format(res.value, MoneyData[rData.moneyType].prettyName),
    })
end

function Rewards.GiveSpins(self, rData, assetData)
    do
        local action = {
            name="addSpin",
            id = assetData.id,
            value=rData.value,
        }
        self.playerState:set(S.Stores, "SpinWheels", action)
    end
end

function Rewards.GiveMonsterSkin(self, rData)
    local skinState = self.playerState:get(S.Stores, "MonsterSkins")
    if skinState.st[rData.assetId] then return end
    do
        local action = {
            name="add",
            id = rData.assetId,
        }
        self.playerState:set(S.Stores, "MonsterSkins", action)
    end
end

function PlayerSpinWheelS:sampleReward(spinWData)
    local idArray, oddsArray = TableUtils.breakKeyValInSyncedArrays(spinWData.odds)

    -- Test
    -- self.rewardSampler:testSampler(idArray, oddsArray)

    local sampleIdx = self.rewardSampler:sampleDiscrete(oddsArray)
    local rewardId = idArray[sampleIdx]
    return rewardId
end

function PlayerSpinWheelS:giveReward(spinWData)
    local rewardId = self:sampleReward(spinWData)
    local rewardData = spinWData.rewards[rewardId]
    for _, hData in ipairs(rewardData.handlers) do
        Rewards[hData.handler](self, hData, spinWData)
    end


    self.SpinWheelUxRE:FireClient(self.player, rewardId)
    local ok, err = self._maid:Add2(
        Promise.fromEvent(self.SpinWheelUxRE.OnServerEvent)
        :timeout(30)
    ):await()
    if not ok then warn(tostring(err)) end
end

function PlayerSpinWheelS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"RequestSpinWheel", "SpinWheelUx"},
        functions = {},
    }))
end

function PlayerSpinWheelS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 0.5},
    })
end

function PlayerSpinWheelS:getFields()
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

function PlayerSpinWheelS:Destroy()
    self._maid:Destroy()
end

return PlayerSpinWheelS