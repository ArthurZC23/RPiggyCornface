local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})

local localPlayer = Players.LocalPlayer
local binderPlayerGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerGameState"})
local playerGameState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerGameState, inst=localPlayer})

local module = {}

function module.open(self, GuiFrame, pageManager)
    local maid = Maid.new()

    -- maid:Add2(GuiFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    --     maid:RemoveWithoutExecution("ClosePage") -- Page was already switched. ClosePage will close the new page
    --     module.close(self)
    -- end))

    maid:Add2(
        Promise.fromEvent(pageManager.SwitchPageSE, function(kwargs)
            return kwargs.previousGui == GuiFrame
        end)
        :andThen(function()
            maid:RemoveWithoutExecution("ClosePage") -- Page was already switched. ClosePage will close the new page
            module.close(self)
        end)
    )

    maid:Add2(function()
        pageManager:close(GuiFrame, false)
    end, "ClosePage")
    pageManager:open(GuiFrame, false)

    return maid
end

function module.close(self)
    self._maid:Remove("Open")
end

local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
function module.handlePageManager(kwargs)
    local maid = Maid.new()
    local controllers = kwargs.controllers
    local tabsData = kwargs.tabsData
    local stateManager = kwargs.stateManager
    local scope = kwargs.scope
    local _action = kwargs.action or "viewTab"
    local stateType = kwargs.stateType or S.LocalSession
    local openTabName = kwargs.openTabName

    maid:Add(function()
        do
            local action = {
                name = "reset",
            }
            stateManager:set(stateType, scope, action)
        end
    end)

    local function update(state)
        local tab = state.viewTab
        local tabData = tabsData[tab]
        local view = controllers[tabData.guiName].view
        maid:Add2(function()
            view:close()
        end, "CloseTab")
        view:open()
    end
    maid:Add(stateManager:getEvent(stateType, scope, _action):Connect(update))

    do
        local action = {
            name = "viewTab",
            tabName = openTabName,
        }
        stateManager:set(stateType, scope, action)
    end

    return maid
end

function module.updateMultipliers(playerState, DevProductContainer, ProductsData, typeEarned, sourceType)
    local maid = Maid.new()
    local function update()
        -- local typeEarned = S.Money_1
        -- local sourceType = S.Money_1Packs
        for id, data in pairs(ProductsData) do
            local _gui = DevProductContainer:FindFirstChild(id)
            if not _gui then continue end
            local value = Calculators.calculate(playerState, typeEarned, data.baseValue, sourceType)
            local productTexts = _gui.Btn.ProductTexts
            productTexts.ShortDescription.TextLabel.Text = ("+%s %s"):format(
                NumberFormatter.numberToEng(value),
                Data.Money.Money[typeEarned].prettyName
            )
        end
    end
    maid:Add(playerState:getEvent("Session", "Multipliers", "updateMultiplier"):Connect(update))
    update()

    return maid
end

function module.updateWithRobloxData(playerState, DevProductContainer, ProductsData)
    local maid = Maid.new()

    local function update(state)
        for id, data in pairs(ProductsData) do
            local stateData = state[id]
            if not stateData then continue end

            local _gui = DevProductContainer:FindFirstChild(id)
            if not _gui then continue end

            local productTexts = _gui.Btn.ProductTexts
            productTexts.Price.Amount.Text = ("%s"):format(stateData.priceInRobux)
        end
    end
    maid:Add(playerGameState:getEvent(S.Session, "DevProducts", "addDevProduct"):Connect(update))
    update(playerGameState:get(S.Session, "DevProducts"))

    return maid
end

local ShopItemUx = require(ReplicatedStorage.Ux.ShopItem)
function module.createStoreGridProducts(kwargs)
    local playerState = kwargs.playerState
    local ProductsData = kwargs.ProductsData
    local DevProductProto = kwargs.DevProductProto
    local DevProductContainer = kwargs.DevProductContainer
    local typeEarned = kwargs.typeEarned
    local sourceType = kwargs.sourceType
    local maid = Maid.new()
    local robuxData = Data.Money.Money[S.Robux]

    for id, data in pairs(ProductsData) do
        local _gui = maid:Add(DevProductProto:Clone())

        _gui:SetAttribute(id)
        local btn = _gui.Btn

        local ProductImage = btn.ProductImage
        ProductImage.Image = data.thumbnail
        ProductImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
        local ProductTexts = btn.ProductTexts
        ProductTexts.Price.ImageLabel.ImageColor3 = robuxData.color
        ProductTexts.Price.ImageLabel.Image = robuxData.thumbnail

        maid:Add(module.purchaseProduct(btn, id))
        ShopItemUx.addUx(btn, nil, data)

        _gui.LayoutOrder = data.LayoutOrder
        _gui.Name = id
        _gui.Visible = true
        _gui.Parent = DevProductContainer
    end

    maid:Add(module.updateMultipliers(playerState, DevProductContainer, ProductsData, typeEarned, sourceType))
    maid:Add(module.updateWithRobloxData(playerState, DevProductContainer, ProductsData))
    return maid
end

function module.purchaseProduct(btn, productId)
    local maid = Maid.new()
    maid:Add(btn.Activated:Connect(function()
        local TryDeveloperPurchaseRE = ComposedKey.getFirstDescendant(ReplicatedStorage, {"Remotes", "Events", "TryDeveloperPurchase"})
        if not TryDeveloperPurchaseRE then return end
        TryDeveloperPurchaseRE:FireServer(productId)
    end))
    return maid
end

return module