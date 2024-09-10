local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local MathFunctionals = Mod:find({"Math", "Functionals"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local GainBackPointsGuiC = {}
GainBackPointsGuiC.__index = GainBackPointsGuiC
GainBackPointsGuiC.className = "GainBackPointsGui"
GainBackPointsGuiC.TAG_NAME = GainBackPointsGuiC.className

function GainBackPointsGuiC.new(RootGui)
    local self = {
        RootGui = RootGui,
        _maid = Maid.new(),
    }
    setmetatable(self, GainBackPointsGuiC)

    if not self:getFields() then return end
    self:handlePointsReset()

    return self
end

local S = Data.Strings.Strings
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function GainBackPointsGuiC:startOffer(previousPoints)
    local maid = Maid.new()

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    local Header = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootGui, refName="Header"})
    if Header then
        local pointsData = Data.Money.Money[S.Points]
        local prettyName = pointsData.prettyNameShort or pointsData.prettyName
        Header.Text = ("Previous %s: %s"):format(prettyName, NumberFormatter.numberToEng(previousPoints))
    end
    self.RootGui:SetAttribute("devProduct", "1715783966")

    maid:Add(function()
        self.RootGui.Visible = false
        CollectionService:RemoveTag(self.RootGui, "DeveloperProductButton")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
    end)
    CollectionService:AddTag(self.RootGui, "DeveloperProductButton")
    self.RootGui.Visible = true

    return maid
end

local Cronos = Mod:find({"Cronos", "Cronos"})
local Promise = Mod:find({"Promise", "Promise"})
local TimeFormatter = Mod:find({"Formatters", "TimeFormatter"})

function GainBackPointsGuiC:setTimer()
    local maid = Maid.new()
    local res = {
        maid = maid,
    }

    res.promise = Promise.try(function()
        local ButtonText = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootGui, refName="ButtonText"})
        local pointsData = Data.Money.Money[S.Points]
        local prettyName = pointsData.prettyNameShort or pointsData.prettyName
        local duration = 10
        local t1 = Cronos:getTime() + duration
        local timeLeft = t1 - Cronos:getTime()
        ButtonText.Text = ("Gain Back %s (%s)"):format(prettyName, TimeFormatter.formatToHHMMSS(math.max(timeLeft, 0)))
        while timeLeft > 0 do
            Cronos.wait(1)
            timeLeft = math.max(t1 - Cronos:getTime(), 0)
            ButtonText.Text = ("Gain Back %s (%s)"):format(prettyName, TimeFormatter.formatToHHMMSS(math.max(timeLeft, 0)))
        end
        ButtonText.Text = ("Gain Back %s (%s)"):format(prettyName, TimeFormatter.formatToHHMMSS(0))
    end)

    return res
end

function GainBackPointsGuiC:handlePurchase()
    local res = {}
    res.promise = Promise.fromEvent(
        self.playerState:getEvent(S.Stores, "Points", "Increment"),
        function(state, action)
            return action.purchasedPointsBack == true
        end
    )
    return res
end

function GainBackPointsGuiC:handlePointsReset()
    local function update(state, action)
        if not action.gainBackPoints then return end
        local maid = self._maid:Add2(Maid.new(), "StartOffer")
        local resTimer = self:setTimer()
        local resHandlePurchase = self:handlePurchase()
        maid:Add(Promise.race({
            resTimer.promise,
            resHandlePurchase.promise,
        }))
        :finally(function()
            self._maid:Remove("StartOffer")
        end)
        maid:Add2(self:startOffer(action.value))
    end

    self._maid:Add(self.playerState:getEvent(S.Stores, "Points", "Decrement"):Connect(update))
    local state = self.playerState:get(S.Stores, "Points")
    update(state, {})
end

function GainBackPointsGuiC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootGui.Parent
        end,
    })
    return ok
end

function GainBackPointsGuiC:Destroy()
    self._maid:Destroy()
end

return GainBackPointsGuiC