local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local LocalDebounce = Mod:find({"Debounce", "Local"})
local Data = Mod:find({"Data", "Data"})

local TrailShopC = {}
TrailShopC.__index = TrailShopC
TrailShopC.className = "TrailShop"
TrailShopC.TAG_NAME = TrailShopC.className

function TrailShopC.new(RootModel)
    local self = {
        _maid = Maid.new(),
        RootModel = RootModel,
    }
    setmetatable(self, TrailShopC)
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

function TrailShopC:showGui()
    local openBtnLikeEvent = SharedSherlock:find({"Bindable", "sync"}, {root=ReplicatedStorage, signal="TrailsBtn"})
    if not openBtnLikeEvent then return end
    openBtnLikeEvent:Fire(true)
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function TrailShopC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.Toucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Toucher"})
            if not self.Toucher then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=1
    })
end

function TrailShopC:Destroy()
    self._maid:Destroy()
end

return TrailShopC