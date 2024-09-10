local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local RootF = script:FindFirstAncestor("PlayerBoostsS")
local BoostsComponents = require(ComposedKey.getAsync(RootF, {"BoostsComponents", "BoostsComponents"}))

local PlayerBoostsS = {}
PlayerBoostsS.__index = PlayerBoostsS
PlayerBoostsS.className = "PlayerBoosts"
PlayerBoostsS.TAG_NAME = PlayerBoostsS.className

function PlayerBoostsS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
        boosts = {},
    }
    setmetatable(self, PlayerBoostsS)

    if not self:getFields() then return end
    self:addBoostComponents()

    -- Use a sorted array because boost ending times can change
    FastSpawn(function()
        self:updateBoostsDurations()
        self:handleQueue()
        self:startBoostClock()
    end)

    return
end

function PlayerBoostsS:handleQueue()
    self._maid:Add2(self.playerState:getEvent("Stores", "Boosts", "addBoost"):Connect(function(state, action)
        self:updateBoostsQueue(action)
    end))

    for boostId, data in pairs(self.playerState:get("Stores", "Boosts").st) do
        self:updateBoostsQueue({
            boostId=boostId,
            duration=data.duration,
            t0=data.t0,
        })
    end
end

function PlayerBoostsS:addBoostComponents()
    for _, component in pairs(BoostsComponents) do
        self._maid:Add(component.new(self.player))
    end
end

function PlayerBoostsS:updateBoostsQueue(action)
    local i = self:findBoost(action.boostId)
    if i then
        self.boosts[i]["t1"] = action.t0 + action.duration
    else
        table.insert(self.boosts, {boostId = action.boostId, t1 = action.t0 + action.duration})
    end
    table.sort(self.boosts, function(a, b)
        return a.t1 < b.t1
    end)
end

function PlayerBoostsS:findBoost(boostId)
    for i, data in ipairs(self.boosts) do
        if data.boostId == boostId then return i, data end
    end
end

function PlayerBoostsS:updateBoostsDurations()
    -- Doens't count while player is offline
    local lastSaveDatetimeIso = self.playerState:get("Stores", "Datetime")
    local lastSaveDatetime = DateTime.fromIsoDate(lastSaveDatetimeIso.ls)

    for boostId, data in pairs(self.playerState:get("Stores", "Boosts").st) do
        local consumedTime = (lastSaveDatetime.UnixTimestamp - data.t0)
        local duration = math.max(data.duration - consumedTime, 0)
        local t0 = Cronos:getTime()

        local action = {
           name="addBoost",
           boostId=boostId,
           duration=duration,
           t0=t0
        }

        self.playerState:set("Stores", "Boosts", action)
    end
end

function PlayerBoostsS:startBoostClock()
    while self.player.Parent do
        Cronos.wait(1)
        local t = Cronos:getTime()
        local nextBoost = self.boosts[1]
        if not nextBoost then continue end
        local t1 = nextBoost.t1
        --print((t1 - t), (t1 - t) / 60, (t1 - t) / 3600)
        if t1 <= t then self:removeFirstBoost() end
    end
end

function PlayerBoostsS:removeFirstBoost()
    local data = table.remove(self.boosts, 1)
    local action = {
       name="removeBoost",
       boostId = data.boostId
    }
    self.playerState:set("Stores", "Boosts", action)
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerBoostsS:getFields()
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

function PlayerBoostsS:Destroy()
    self._maid:Destroy()
end

return PlayerBoostsS