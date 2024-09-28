local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Maid = Mod:find({"Maid"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local ButtonRing = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="ButtonRing"})
local GamepadInput = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GamepadInput"})
local KeyboardInput = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="KeyboardInput"})

local View = {}
View.__index = View
View.className = "CrawlView"
View.TAG_NAME = View.className

function View.new(ctrl)
    local self = {
        _maid = Maid.new(),
        ctrl = ctrl,
        charState = ctrl.charState,
    }
    setmetatable(self, View)
    if not self:getFields() then return end
    self:handleButtonColors()
    self:showPlayerInput()


    return self
end

function View:handleButtonColors()
    local function update(state)
        if state.on then
            ButtonRing.ImageColor3 = Color3.fromRGB(47, 182, 23)
        else
            ButtonRing.ImageColor3 = Color3.fromRGB(0, 0, 0)
        end
    end
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Crawl", "set"):Connect(update))
    local state = self.charState:get(S.LocalSession, "Crawl")
    update(state)
end

local UserInputService = game:GetService("UserInputService")
function View:showPlayerInput()
    local function updateGamepadView(state)
        local gamepads = UserInputService:GetConnectedGamepads()
        if next(gamepads) then
            GamepadInput.Visible = true
        else
            GamepadInput.Visible = false
        end
    end
    self._maid:Add(UserInputService.GamepadDisconnected:Connect(updateGamepadView))
    self._maid:Add(UserInputService.GamepadConnected:Connect(updateGamepadView))
    updateGamepadView()

    local hasKeyboard = UserInputService.KeyboardEnabled
    if hasKeyboard then
        KeyboardInput.Visible = true
    end
end

function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {}
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

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