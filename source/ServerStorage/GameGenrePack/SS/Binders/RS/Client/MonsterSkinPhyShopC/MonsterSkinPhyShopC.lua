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

local MonsterSkinPhyShopC = {}
MonsterSkinPhyShopC.__index = MonsterSkinPhyShopC
MonsterSkinPhyShopC.className = "MonsterSkinPhyShop"
MonsterSkinPhyShopC.TAG_NAME = MonsterSkinPhyShopC.className

function MonsterSkinPhyShopC.new(RootModel)
    local self = {
        _maid = Maid.new(),
        RootModel = RootModel,
    }
    setmetatable(self, MonsterSkinPhyShopC)
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

function MonsterSkinPhyShopC:showGui()
    for _, controller in ipairs({"ShopTabController"}) do
        local view = self.playerGuis.controllers[controller].view
        view:open({tabName = S.MonsterSkins})
    end
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

function MonsterSkinPhyShopC:getFields()
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

function MonsterSkinPhyShopC:Destroy()
    self._maid:Destroy()
end

return MonsterSkinPhyShopC