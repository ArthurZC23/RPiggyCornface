local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
local AssetsUtils = Mod:find({"Assets", "Shared", "Utils"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local ViewUtils = Mod:find({"Gui", "ViewUtils"})

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local BecomeMonsterPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BecomeMonsterPage"})
local Vpf = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="Vpf"})
local ChangeSkinBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="ChangeSkinBtn"})
local Money_1KillRatioText = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="Money_1KillRatioText"})
local TimeMoneyMonsterRatioText = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="TimeMoneyMonsterRatioText"})
local MoneyMonsterAmount = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="MoneyMonsterAmount"})
local LessMoneyMonsterBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="LessMoneyMonsterBtn"})
local MoreMoneyMonsterBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="MoreMoneyMonsterBtn"})
local BecomeMonsterBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="BecomeMonsterBtn"})
local MoneyPaymentText = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="MoneyPaymentText"})
local DevProductProto = SharedSherlock:find({"EzRef", "Get"}, {inst=BecomeMonsterPage, refName="DevProductProto"})
local DevProductContainer = DevProductProto.Parent
DevProductProto.Parent = nil
local tabPageManager = ClientSherlock:find({"PageManager", "BecomeMonster"})
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BecomeMonsterPage"})
tabPageManager:addGui(TabPage)

local View = {}
View.__index = View
View.className = "BecomeMonsterView"
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

    return self
end

function View:handleVpf()
    local playerState = self.controller.playerState
    local maid = Maid.new()
    local function update(state)
        local _maid = maid:Add2(Maid.new(), "updateVpf")
        local skinId = state.eq
        local data = Data.MonsterSkins.MonsterSkins.idData[skinId]
        AssetsUtils.setModel(Vpf, "MonsterSkin", {
            id = skinId,
            cameraProps = data.vpf,
            WorldModel = Vpf.WorldModel
        })
        local Model = Vpf.Model
        Model:PivotTo(CFrame.new(0, 0, 0))
        _maid:Add(Vpf.Model)
    end
    maid:Add(playerState:getEvent(S.Stores, "MonsterSkins", "eq"):Connect(update))
    local state = playerState:get(S.Stores, "MonsterSkins")
    update(state)
    return maid
end

function View:handleTextInfo()
    local maid = Maid.new()

    local playerState = self.controller.playerState
    TimeMoneyMonsterRatioText.Text = ("1 %s = %s minute"):format(
        Data.Money.Money[S.MoneyMonster].viewNameSingular,
        Data.MonsterSkins.MonsterSkins.playerMonster.timeMoneyMonsterRatio / 60
    )
    --------------
    Money_1KillRatioText.Visible = true
    Money_1KillRatioText.Text = ("1 Kill = %s %s"):format(
        Data.MonsterSkins.MonsterSkins.playerMonster.money_1KillRatio,
        Data.Money.Money[S.Money_1].prettyName
    )
    --------------
    local function update(state)
        MoneyMonsterAmount.Text = state.current
    end
    self._maid:Add(playerState:getEvent(S.Stores, "MoneyMonster", "Update"):Connect(update))
    local state = playerState:get(S.Stores, "MoneyMonster")
    update(state)

    return maid
end

function View:handleUseButton()
    local maid = Maid.new()
    local playerState = self.controller.playerState
    maid:Add2(localPlayer:GetAttributeChangedSignal("moneyPayment"):Connect(function()
        MoneyPaymentText.Text = ("Use (%s)"):format(localPlayer:GetAttribute("moneyPayment"))
    end))
    localPlayer:SetAttribute("moneyPayment", 0)
    maid:Add2(LessMoneyMonsterBtn.Activated:Connect(function()
        localPlayer:SetAttribute("moneyPayment", math.max(localPlayer:GetAttribute("moneyPayment") - 1, 0))
    end))
    maid:Add2(MoreMoneyMonsterBtn.Activated:Connect(function()
        local maxValue = playerState:get(S.Stores, "MoneyMonster").current
        localPlayer:SetAttribute("moneyPayment", math.min(localPlayer:GetAttribute("moneyPayment") + 1, maxValue))
    end))
    maid:Add2(BecomeMonsterBtn.Activated:Connect(function()
        local payment = localPlayer:GetAttribute("moneyPayment")
        if payment <= 0 then return end
        local BecomeMonsterRE = ComposedKey.getEvent(localPlayer, "BecomeMonster")
        if not BecomeMonsterRE then return end
        BecomeMonsterRE:FireServer(localPlayer:GetAttribute("moneyPayment"))
        self.controller.playerGuis.controllers.BecomeMonsterTabsController.view:close()
    end))
    return maid
end

function View:addMoneyMonsterStore()
    local maid = Maid.new()

    local playerState = self.controller.playerState
    local ProductsData = Data.Shop.ShopProducts.products.MoneyMonster
    maid:Add(ViewUtils.createStoreGridProducts({
        playerState = playerState,
        ProductsData = ProductsData,
        DevProductProto = DevProductProto,
        DevProductContainer = DevProductContainer,
        typeEarned = "MoneyMonster",
        sourceType = S.MoneyMonsterPacks,
    }))

    return maid
end

function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(self:handleTextInfo())
    maid:Add(self:addMoneyMonsterStore())
    maid:Add(self:handleUseButton())
    maid:Add(self:handleVpf())
    -- ChangeSkinBtn.Parent.Visible = false
    maid:Add(self.controller:handleChangeSkin(ChangeSkinBtn))
    maid:Add2(ViewUtils.open(self, TabPage, tabPageManager))
end

function View:close()
    ViewUtils.close(self)
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