local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)

local localPlayer = Players.LocalPlayer

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local BuyMoreTimeBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BuyMoreTimeBtn"})
local TimerText = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="TimerText"})

local View = {}
View.__index = View
View.className = "MonsterTimerView"
View.TAG_NAME = View.className

local function setAttributes()

end
setAttributes()

function View.new(controller)
    local self = {
        _maid = Maid.new(),
        controller = controller,
        teamGui = "monster",
    }
    setmetatable(self, View)
    if not self:getFields() then return end

    return self
end

local binderPlayerGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerGameState"})
local playerGameState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerGameState, inst=localPlayer})
local Cronos = Mod:find({"Cronos", "Cronos"})
local TimeFormatter = Mod:find({"Formatters", "TimeFormatter"})

function View:handleTimer()
    local maid = Maid.new()

    local function update(state)
        local _maid = maid:Add2(Maid.new(), "Timer")
        if not state.t1 then return end
        if state.playerId ~= localPlayer.UserId then return end
        local t0 = Cronos:getTime()
        local duration = math.max(state.t1 - t0, 0)
        TimerText.Text = TimeFormatter.formatSecondsToMMSS(duration)
        _maid:Add2(Promise.try(function()
            while duration > 0 do
                task.wait(1)
                t0 = Cronos:getTime()
                duration = math.max(state.t1 - t0, 0)
                TimerText.Text = TimeFormatter.formatSecondsToMMSS(duration)
            end
        end))
    end
    maid:Add(playerGameState:getEvent(S.Session, "Monster", "setPlayerMonster"):Connect(update))
    local state = playerGameState:get(S.Session, "Monster")
    update(state)

    return maid
end

local ViewUtils = Mod:find({"Gui", "ViewUtils"})
function View:createGui()
    local maid = Maid.new()
    maid:Add2(self:handleTimer())
    maid:Add2(ViewUtils.purchaseProduct(BuyMoreTimeBtn, "1886021777"))
    return maid
end

function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(self:createGui())
    maid:Add2(function()
        GuiFrame.Visible = false
    end)
    GuiFrame.Visible = true
end

function View:close()
    self._maid:Remove("Open")
end

function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function View:Destroy()
    self._maid:Destroy()
end

return View