local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local function setAttributes()

end
setAttributes()

local PlayerPointGiverS = {}
PlayerPointGiverS.__index = PlayerPointGiverS
PlayerPointGiverS.className = "PlayerPointGiver"
PlayerPointGiverS.TAG_NAME = PlayerPointGiverS.className

function PlayerPointGiverS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
        queue = {},
    }
    setmetatable(self, PlayerPointGiverS)

    if not self:getFields() then return end
    -- self:setPlayerNetwork()
    -- self:createRemotes()
    self:updatePointsRate()
    self:givePointsOverTime()
    self:handleGainBackPoints()

    return self
end

function PlayerPointGiverS:handleGainBackPoints()
    local function update(state, action)
        if not action.gainBackPoints then return end
        self.playerState.player:SetAttribute("previousPointsForGain", action.value)
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Points", "Decrement"):Connect(update))
    local state = self.playerState:get(S.Stores, "Points")
    update(state, {})
end

local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
function PlayerPointGiverS:updatePointsRate()
    local function update()
        local money_1State = self.playerState:get(S.Stores, "Money_1")
        local money_1 = money_1State.current
        local pointsRate = math.ceil(0.2 * money_1 + 0.9) -- check #46

        pointsRate = Calculators.calculate(self.playerState, S.Points, pointsRate, S.Idle)
        do
            local action = {
                name = "SetRate",
                value = pointsRate,
            }
            self.playerState:set(S.Stores, S.Points, action)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "Multipliers", "updateMultiplier"):Connect(update))
    self._maid:Add(self.playerState:getEvent(S.Stores, "Money_1", "Update"):Connect(update))
    update()
end

local BigBen = Mod:find({"Cronos", "BigBen"})
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
function PlayerPointGiverS:givePointsOverTime()
    self._maid:Add(BigBen.every(1, "Heartbeat", "time_", true):Connect(function()
        local points = self.playerState:get(S.Stores, "Points").rate
        -- Points rate already has multipler, so no need for giver here.
        do
            local action = {
                name = "Increment",
                value = points,
            }
            self.playerState:set(S.Stores, S.Points, action)
        end
    end))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerPointGiverS:getFields()
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

function PlayerPointGiverS:Destroy()
    self._maid:Destroy()
end

return PlayerPointGiverS