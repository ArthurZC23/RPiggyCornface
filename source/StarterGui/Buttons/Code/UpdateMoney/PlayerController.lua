local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local moneyAmountText = {
    Money_1 = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Money_1Amount"}),
}

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "UpdateMoneyController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
        player = playerGuis.player,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self:handleMoney()
    return self
end

function Controller:handleMoney()
    local playerState = self.playerGuis.playerState
    for moneyType, textLabel in pairs(moneyAmountText) do
        local function update(state, action)
            textLabel.Text = NumberFormatter.numberToEng(state.current)
        end
        playerState:getEvent(S.Stores, moneyType, "Update"):Connect(update)
        local state = playerState:get(S.Stores, moneyType)
        update(state)
    end
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local char = localPlayer.Character
            if not (char and char.Parent) then return end
            local bindersData = {

            }
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

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller

