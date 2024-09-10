local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Bach = Mod:find({"Bach", "Bach"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local TimeFormatter = Mod:find({"Formatters", "TimeFormatter"})
local SignalE = Mod:find({"Signal", "Event"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local MultiplierMath = Mod:find({"Hamilton", "MultiplierMath"})
local TableUtils = Mod:find({"Table", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local Data = Mod:find({"Data", "Data"})
local ChestsData = Data.Chests.Chests
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local PlayerChestC = {}
PlayerChestC.__index = PlayerChestC
PlayerChestC.TAG_NAME = "PlayerChest"

function PlayerChestC.new(player)
    if localPlayer ~= player then return end
	local self = {
        _maid = Maid.new(),
        player = player,
    }
	setmetatable(self, PlayerChestC)

    if not self:getFields() then return end
    self:handleChests()
    self:updateAmount()

	return self
end

local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
function PlayerChestC:updateAmount()
    local function update()
        for chestId, chestData in pairs(Data.Chests.Chests.idData) do
            local chestObj = SharedSherlock:find({"Binders", "getInstById"}, {tag="Chest", id=chestId})
            if not chestObj then return end
            for i, rData in ipairs(chestData.rewards) do
                local SingleReward = chestObj.RewardContainer:FindFirstChild(tostring(i))
                if not SingleReward then continue end
                local moneyType = rData.moneyType
                local sourceType = rData.sourceType
                local value = Calculators.calculate(self.playerState, moneyType, rData.baseValue, sourceType)
                SingleReward.Amount.Text = NumberFormatter.numberToEng(value)
            end
        end
    end
    self._maid:Add(self.playerState:getEvent("Session", "Multipliers", "updateMultiplier"):Connect(update))
    update()
end

function PlayerChestC:handleChests()
    self._maid:Add(self.playerState:getEvent("Stores", "Chests", "openChest"):Connect(function(state, action)
        local t1 = state[action.id]
        local chestObj = SharedSherlock:find({"Binders", "getInstById"}, {tag="Chest", id=action.id})
        if not chestObj then return end
        local timerSignal = chestObj:getTimerSignal()
        timerSignal:Fire("startTimer", t1)
    end))

    self._maid:Add(self.playerState:getEvent("Stores", "Chests", "resetChest"):Connect(function(state, action)
        local chestObj = SharedSherlock:find({"Binders", "getInstById"}, {tag="Chest", id=action.id})
        if not chestObj then return end
        local timerSignal = chestObj:getTimerSignal()
        timerSignal:Fire("finishTimer")
    end))

    local chestState = self.playerState:get(S.Stores, "Chests")
    for chestId, t1 in pairs(chestState) do
        self._maid:Add2(WaitFor.Get({
            getter = function()
                local chestObj = SharedSherlock:find({"Binders", "getInstById"}, {tag="Chest", id=chestId})
                if not chestObj then return end
                return chestObj
            end,
            keepTrying = function()
                return self.player.Parent
            end,
            cooldown = 1,
        })
        :andThen(function(chestObj)
            local t0 = Cronos:getTime()
            if t1 - t0 > 0 then
                local timerSignal = chestObj:getTimerSignal()
                timerSignal:Fire("startTimer", t1)
            else
                local timerSignal = chestObj:getTimerSignal()
                timerSignal:Fire("finishTimer")
            end
        end))
    end
end

local BinderUtils = Mod:find({"Binder", "Utils"})
function PlayerChestC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player}
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

function PlayerChestC:Destroy()
    self._maid:Destroy()
end

return PlayerChestC