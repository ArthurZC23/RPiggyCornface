local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
local GaiaShared = Mod:find({"Gaia", "Shared"})

local localPlayer = Players.LocalPlayer
local PlayerGui  = localPlayer:WaitForChild("PlayerGui")
local ButtonsGui = PlayerGui:WaitForChild("Buttons")

local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local ExitButton = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="ExitButton"}):WaitForChild("Exit")

local openShopButtonsData = {
    {
        frame = SharedSherlock:find({"EzRef", "Get"}, {inst=ButtonsGui, refName="ShopBtn"}),
        kwargs = {
            tabName = "Trails",
        },
    },
    {
        frame = SharedSherlock:find({"EzRef", "Get"}, {inst=ButtonsGui, refName="OpenMoney_1ShopFr"}),
        kwargs = {
            tabName = "Money_1",
        },
    },
}

pageManager:addGui(GuiFrame)

local Controller = {}
Controller.__index = Controller
Controller.className = "ShopButtonController"

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self:createSignals()

    self:handleButtonExits()
    self:handleOpenSignal()
    self:handleOpenButton()
    self:addBtnUx()

    return self
end

function Controller:handleButtonExits()
    self._maid:Add(ExitButton.Activated:Connect(function()
        for _, controller in ipairs({"ShopTabController"}) do
            local view = self.playerGuis.controllers[controller].view
            view:close()
        end
    end))
end

function Controller:open(kwargs)
    for _, controller in ipairs({"ShopTabController"}) do
        local view = self.playerGuis.controllers[controller].view
        view:open(kwargs)
    end
end

function Controller:handleOpenSignal()
    self._maid:Add2(self.OpenShopSE:Connect(function(kwargs)
        self:open(kwargs)
    end))
end

function Controller:handleOpenButton()
    for i, shopData in ipairs(openShopButtonsData) do
        local Btn = shopData.frame.Btn
        self._maid:Add2(Btn.Activated:Connect(function()
            self:open(shopData.kwargs)
        end))
    end
end

function Controller:addBtnUx()
    for i, shopData in ipairs(openShopButtonsData) do
        local Btn = shopData.frame.Btn
        self._maid:Add2(ButtonsUx.addUx(Btn, {
            dilatation = {
                expandFactor = {
                    X=1.1,
                    Y=1.1,
                }
            }
        }))
    end
    do
        self._maid:Add2(ButtonsUx.addUx(ExitButton, {
            dilatation = {
                expandFactor = {
                    X=1.1,
                    Y=1.1,
                }
            }
        }))
    end
end

function Controller:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, localPlayer, {
        events = {"OpenShop"},
    }))
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {}
            local root = localPlayer
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
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