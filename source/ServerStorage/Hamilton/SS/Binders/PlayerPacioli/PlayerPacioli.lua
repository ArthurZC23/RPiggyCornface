local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local S = Data.Strings.Strings
local TimeUnits = Data.Date.TimeUnits
local Promise = Mod:find({"Promise", "Promise"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerPacioli = {}
PlayerPacioli.__index = PlayerPacioli
PlayerPacioli.className = "PlayerPacioli"
PlayerPacioli.TAG_NAME = PlayerPacioli.className

PlayerPacioli.timeIntervals = {
    TimeUnits.minute,
    5 * TimeUnits.minute,
    -- 10 * TimeUnits.minute,
}

PlayerPacioli.incomesData = {
    -- {
    --     scoreType = "Money_1",
    -- },
}

function PlayerPacioli.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerPacioli)

    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end
    self:handleIncomes(playerState)

    return self
end

function PlayerPacioli:handleIncomes(playerState)
    for _, incomeData in pairs(self.incomesData) do
        for _, tInterval in ipairs(self.timeIntervals) do
            self:_handleIncomeTimer(playerState, incomeData, tInterval)
        end
    end
end

function PlayerPacioli:_handleIncomeTimer(playerState, data, tInterval)
    local stateType = data.stateType or S.Stores
    local scoreType = data.scoreType
    local str = ("IncomeTimerPromise%s%s"):format(scoreType, tInterval / TimeUnits.minute)
    local value0 = playerState:get(stateType, "Scores")[scoreType]["allTime"]

    local p = Promise.delay(tInterval)
        :andThen(function ()
            local value1 = playerState:get(stateType, "Scores")[scoreType]["allTime"]
            local rate = (value1 - value0) / (tInterval / TimeUnits.minute)
            -- if RunService:IsStudio() then
            --     print(("Income Rate %s %s: %s"):format(scoreType, (tInterval / TimeUnits.minute), NumberFormatter.numberToEng(rate)))
            -- end

            -- do something with rate

            self._maid:Remove(str)
            if not self.player.Parent then return end
            if playerState.isDestroyed then return end

            task.spawn(function()
                self:_handleIncomeTimer(playerState, data, tInterval)
            end)

        end)
    self._maid:Add(p, "cancel", str)
end

-- function PlayerPacioli:handleExpenses(playerState)
--     for _, expenseData in pairs(self.expensesData) do
--         for _, tInterval in ipairs(self.timeIntervals) do
--             self:_handleExpenseTimer(playerState, expenseData, tInterval)
--         end
--     end
-- end

-- function PlayerPacioli:_handleExpenseTimer(playerState, data, tInterval)
--     local stateType = data.stateType or S.Stores
--     local scope = data.scope
--     local key = data.key or "current"
--     local str = ("ExpenseTimerPromise%s%s"):format(scope, tInterval / TimeUnits.minute)
--     local value0 = playerState:get(stateType, scope)[key]
--     local p = Promise.delay(tInterval)
--         :andThen(function ()
--             local value1 = playerState:get(stateType, "Points")[key]
--             local rate = (value1 - value0) / tInterval
--             if RunService:IsStudio() then
--                 print(("Expense Rate %s %s: %s"):format(scope, tInterval, NumberFormatter.numberToEng(rate)))
--             end

--             -- do something with rate

--             self._maid:Remove(str)
--             if not self.player.Parent then return end
--             if playerState.isDestroyed then return end

--             task.spawn(function()
--                 self:_handleIncomeTimer(playerState, tInterval)
--             end)

--         end)
--     self._maid:Add(p, "cancel", str)
-- end

function PlayerPacioli:Destroy()
    self._maid:Destroy()
end

return PlayerPacioli