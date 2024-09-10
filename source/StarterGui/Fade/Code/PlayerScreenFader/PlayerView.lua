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
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
local Promise = Mod:find({"Promise", "Promise"})
local PromiseUtils = Mod:find({"Promise", "Utils"})

local localPlayer = Players.LocalPlayer

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local FadeScreen = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="FadeScreen"})
local Texts = {
    CenterText = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="CenterText"})
}

local View = {}
View.__index = View
View.className = "PlayerScreenFaderView"
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
    self:handleScreenFader()

    return self
end

function View:fadeOut(kwargs)
    local res = {}
    local tweenInfo = TweenInfo.new(kwargs.duration)
    local goal = {BackgroundTransparency = 0}
    local tween = TweenService:Create(FadeScreen, tweenInfo, goal)
    tween:Play()
    res.promise = Promise.fromEvent(tween.Completed)
    return res
end

function View:fadeIn(kwargs)
    local res = {}
    local tweenInfo = TweenInfo.new(kwargs.duration)
    local promises = {}
    do
        local goal = {BackgroundTransparency = 1}
        local tween = TweenService:Create(FadeScreen, tweenInfo, goal)
        tween:Play()
        table.insert(promises, Promise.fromEvent(tween.Completed))
    end
    for _, Text in pairs(Texts) do
        if not Text.Visible then continue end
        local goal = {TextTransparency = 1, TextStrokeTransparency = 1}
        local tween = TweenService:Create(Text, tweenInfo, goal)
        tween:Play()
        table.insert(promises, Promise.fromEvent(tween.Completed))
    end
    res.promise = Promise.all(promises)
    return res
end

function View:setText(kwargs)
    local res = {}
    local refName = kwargs.refName or "CenterText"
    local Text = Texts[refName]
    Text.TextColor3 = kwargs.TextColor or Color3.fromRGB(255, 255, 255)

    Text.TextTransparency = 1
    Text.TextStrokeTransparency = 1
    local goal = {TextTransparency = 0, TextStrokeTransparency = 0}
    local tweenInfo = TweenInfo.new(kwargs.duration or 0.25)
    local tween = TweenService:Create(Text, tweenInfo, goal)

    Text.Text = kwargs.Text
    Text.Visible = true
    tween:Play()
    res.promise = tween.Completed

    return res
end

function View:continueText(kwargs)
    local res = {}
    local refName = kwargs.refName or "CenterText"
    local Text = Texts[refName]

    Text.Text = ("%s%s"):format(Text.Text, kwargs.Text)
    Text.Visible = true

    return res
end

function View:wait(kwargs)
    local res = {}

    res.promise = Promise.delay(kwargs.duration)

    return res
end

local Functional = Mod:find({"Functional"})
function View:handleScreenFader()
    local function fadeOut(state)
        local methods = Functional.map(state.fadeOut.methods, function(methodData)
            return TableUtils.concatArrays({self}, methodData)
        end)
        PromiseUtils.eachMethod(methods)
    end
    local function fadeIn(state)
        local methods = Functional.map(state.fadeIn.methods, function(methodData)
            return TableUtils.concatArrays({self}, methodData)
        end)
        PromiseUtils.eachMethod(methods)
    end
    local playerState = self.controller.playerState
    self._maid:Add(playerState:getEvent(S.Session, "ScreenFader", "fadeIn"):Connect(fadeIn))
    self._maid:Add(playerState:getEvent(S.Session, "ScreenFader", "fadeOut"):Connect(fadeOut))
    local state = playerState:get(S.Session, "ScreenFader")
    if state.fadeOut then
        fadeOut(state)
    end
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