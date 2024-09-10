local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local DeveloperProductBlockC = {}
DeveloperProductBlockC.__index = DeveloperProductBlockC
DeveloperProductBlockC.className = "DeveloperProductBlock"
DeveloperProductBlockC.TAG_NAME = DeveloperProductBlockC.className

function DeveloperProductBlockC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, DeveloperProductBlockC)

    if not self:getFields() then return end
    self:handleTouch()
    self:setView()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function DeveloperProductBlockC:handleTouch()
    self._maid:Add2(self.Toucher.Touched:Connect(LocalDebounce.playerHrpCooldown(
        function()
            local TryDeveloperPurchaseRE = ComposedKey.getEvent(ReplicatedStorage, "TryDeveloperPurchase")
            if not TryDeveloperPurchaseRE then return end
            TryDeveloperPurchaseRE:FireServer(self.devProduct)
        end,
        0.5
    )))
end

local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function DeveloperProductBlockC:setView()
    self.BillboardGui.AlwaysOnTop = true
    self.BillboardGui.MaxDistance = 512
    local shopBlocksData = Data.Shop.ShopDevProductBlocks.idData[self.devProduct]
    if shopBlocksData.moneyType then
        local moneyType = shopBlocksData.moneyType
        local moneyData = Data.Money.Money[moneyType]
        local color = moneyData.color
        self.Base.Color = color
        self.ProductName.TextColor3 = color
        self.Thumbnail.Image = moneyData.thumbnail

        local function update()
            local baseValue = shopBlocksData.baseValue
            local sourceType = shopBlocksData.sourceType
            local value = Calculators.calculate(self.playerState, moneyType, baseValue, sourceType)
            self.ProductName.Text = ("+%s %s"):format(
                NumberFormatter.numberToEng(value), moneyData.prettyName)
        end
        self._maid:Add(self.playerState:getEvent(S.Session, "Multipliers", "updateMultiplier"):Connect(update))
        update()
    end
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function DeveloperProductBlockC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.devProduct = self.RootModel:GetAttribute("devProduct")
            if not self.devProduct then return end

            self.Base = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Base"})
            if not self.Base then return end

            self.Toucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Toucher"})
            if not self.Toucher then return end

            self.BillboardGui = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="BillboardGui"})
            if not self.BillboardGui then return end

            self.ProductName = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="ProductName"})
            if not self.ProductName then return end

            self.Thumbnail = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Thumbnail"})
            if not self.Thumbnail then return end

            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=nil
    })
end

function DeveloperProductBlockC:Destroy()
    self._maid:Destroy()
end

return DeveloperProductBlockC