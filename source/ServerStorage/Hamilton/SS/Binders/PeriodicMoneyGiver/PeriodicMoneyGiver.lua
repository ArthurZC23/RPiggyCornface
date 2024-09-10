local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local BigBen = Mod:find({"Cronos", "BigBen"})
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Promise = Mod:find({"Promise", "Promise"})

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local ONE_MINUTE = 60
local PERIOD = 9

-- if RunService:IsStudio() then
--     ONE_MINUTE = 0.1
-- end

local PeriodicMoneyGiverS = {}
PeriodicMoneyGiverS.__index = PeriodicMoneyGiverS
PeriodicMoneyGiverS.className = "PeriodicMoneyGiver"
PeriodicMoneyGiverS.TAG_NAME = PeriodicMoneyGiverS.className

function PeriodicMoneyGiverS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PeriodicMoneyGiverS)

    if not self:getFields() then return end
    self:moneyGiver()

    return self
end

function PeriodicMoneyGiverS:moneyGiver()
    local attr = "FinishLoadingScreen"
    local function run()
        self._maid:Add2(Promise.delay(5):andThen(function ()
            self:_moneyGiver()
        end))
    end
    if self.player:GetAttribute(attr) then
        run()
    else
        self._maid:Add2(Promise.fromEvent(self.player:GetAttributeChangedSignal(attr)):andThen(run))
    end
end

function PeriodicMoneyGiverS:_moneyGiver()
    local money_1_value = 225
    -- if RunService:IsStudio() then
    --     money_1_value = 1e6
    --     -- money_1_value = 1e9 - 1
    -- end

    self:warnAboutNextIncome()
    self._maid:Add2(BigBen.every(PERIOD * ONE_MINUTE, "Stepped", "time_", false):Connect(function()
        if not self.playerState then return end
        do
            local typeEarned = S.Money_1
            local value = money_1_value
            local sourceType = S.TimePeriod
            Giver.give(self.playerState, typeEarned, value, sourceType)
        end
        self:warnAboutNextIncome()
    end))
end

function PeriodicMoneyGiverS:warnAboutNextIncome()
    NotificationStreamRE:FireClient(self.playerState.player, {
        Text = ("Next paycheck in %s minutes!"):format(PERIOD),
    })
end

function PeriodicMoneyGiverS:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            -- local remotes = {

            -- }
            -- local root
            -- if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
    return ok
end

function PeriodicMoneyGiverS:Destroy()
    self._maid:Destroy()
end

return PeriodicMoneyGiverS