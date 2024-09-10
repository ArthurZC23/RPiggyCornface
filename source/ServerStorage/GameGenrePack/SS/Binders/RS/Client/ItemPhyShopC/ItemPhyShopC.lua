local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local LocalDebounce = Mod:find({"Debounce", "Local"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local ItemPhyShopC = {}
ItemPhyShopC.__index = ItemPhyShopC
ItemPhyShopC.className = "ItemPhyShop"
ItemPhyShopC.TAG_NAME = ItemPhyShopC.className

function ItemPhyShopC.new(RootModel)
    local self = {
        _maid = Maid.new(),
        RootModel = RootModel,
    }
    setmetatable(self, ItemPhyShopC)
    if not self:getFields() then return end

    self.Toucher.Touched:Connect(LocalDebounce.playerLimbExecutionCooldown(
        function()
            self:showGui()
        end,
        1,
        "Hrp"
    ))

    return self
end

function ItemPhyShopC:showGui()
    local openBtnLikeEvent = SharedSherlock:find({"Bindable", "sync"}, {root=ReplicatedStorage, signal="OpenItemShop"})
    if not openBtnLikeEvent then return end
    openBtnLikeEvent:Fire(true)
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

function ItemPhyShopC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.Toucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Toucher"})
            if not self.Toucher then return end

            local bindersData = {
                {"PlayerGuis", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=1
    })
end

function ItemPhyShopC:Destroy()
    self._maid:Destroy()
end

return ItemPhyShopC