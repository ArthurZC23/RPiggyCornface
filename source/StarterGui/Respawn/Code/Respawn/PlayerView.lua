local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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
local GuiClasses = Mod:find({"Gui", "GuiClasses"})
local GridLayout = require(GuiClasses.Layout.Grid.Grid)
local AssetsUtils = Mod:find({"Assets", "Shared", "Utils"})
local Debounce = Mod:find({"Debounce", "Debounce"})

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local LifeProto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="LifeProto"})
local LivesContainer = LifeProto.Parent
local ContinueText = SharedSherlock:find({"EzRef", "GetSync"}, {inst=gui, refName="ContinueText"})
local TimerBar = SharedSherlock:find({"EzRef", "GetSync"}, {inst=gui, refName="TimerBar"})
local BuyLifeBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BuyLifeBtn"})
LifeProto.Parent = nil

local View = {}
View.__index = View
View.className = "RespawnView"
View.TAG_NAME = View.className

local function setAttributes()

end
setAttributes()

function View.new(controller)
    local self = {
        _maid = Maid.new(),
        controller = controller,
    }
    setmetatable(self, View)
    if not self:getFields() then return end
    self:setLives()

    return self
end

function View:setLives()
    for i = 1, Data.Map.Map.maxLives do
        local _gui = LifeProto:Clone()
        _gui.Name = tostring(i)
        _gui.LayoutOrder = i
        _gui.Parent = LivesContainer
    end
end

local BigBen = Mod:find({"Cronos", "BigBen"})
function View:setTimer()
    local maid = Maid.new()

    local res = {
        maid = maid,
    }

    TimerBar.Size = UDim2.fromScale(1, 1)
    local totalDuration = Data.Map.Map.buyNewLifeDuration
    Promise.try(function()
        local duration = totalDuration
        ContinueText.Text = ("CONTINUE (+1 LIFE) %s s"):format(duration)
        maid:Add(BigBen.every(1, "Heartbeat", "frame", true):Connect(function(_, timeStep)
            duration = math.max(duration - timeStep, 0)
            ContinueText.Text = ("CONTINUE (+1 LIFE) %s s"):format(math.ceil(duration))
            TimerBar.Size = UDim2.fromScale((1/totalDuration) * duration, 1)
        end))
    end)

    return res
end

function View:handleLifeCount()
    local maid = Maid.new()
    local playerState = self.controller.playerState
    maid:Add(function()
        for i = 1, Data.Map.Map.maxLives do
            local _gui = LivesContainer:FindFirstChild(tostring(i))
            if not _gui then continue end
            _gui.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
        end
    end)
    local function update(state)
        for i = 1, state.cur do
            local _gui = LivesContainer:FindFirstChild(tostring(i))
            if not _gui then continue end
            _gui.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        for i = state.cur + 1, Data.Map.Map.maxLives do
            local _gui = LivesContainer:FindFirstChild(tostring(i))
            if not _gui then continue end
            _gui.ImageLabel.ImageColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
    maid:Add(playerState:getEvent(S.Session, "Lives", "update"):Connect(update))
    local state = playerState:get(S.Session, "Lives")
    update(state)
    return maid
end

local DisableGuisSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="DisableGuis"})
function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add2(function()
        DisableGuisSE:Fire("Enable")
        GuiFrame.Visible = false
    end)

    maid:Add(self:handleLifeCount())
    local resTimer = self:setTimer()
    maid:Add(resTimer.maid)
    maid:Add(self.controller:handlePurchaseLife(BuyLifeBtn))

    pageManager:close()
    DisableGuisSE:Fire("Disable", "exceptions", {
        ["Fade"] = true,
        ["Respawn"] = true,
    })
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