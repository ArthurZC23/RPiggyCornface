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

local BecomeMonsterPhyShopC = {}
BecomeMonsterPhyShopC.__index = BecomeMonsterPhyShopC
BecomeMonsterPhyShopC.className = "BecomeMonsterPhyShop"
BecomeMonsterPhyShopC.TAG_NAME = BecomeMonsterPhyShopC.className

function BecomeMonsterPhyShopC.new(RootModel)
    local self = {
        _maid = Maid.new(),
        RootModel = RootModel,
    }
    setmetatable(self, BecomeMonsterPhyShopC)
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

function BecomeMonsterPhyShopC:showGui()
    local view = self.playerGuis.controllers["BecomeMonsterTabsController"].view
    view:open({tabName = "BecomeMonster"})
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

function BecomeMonsterPhyShopC:getFields()
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

function BecomeMonsterPhyShopC:Destroy()
    self._maid:Destroy()
end

return BecomeMonsterPhyShopC