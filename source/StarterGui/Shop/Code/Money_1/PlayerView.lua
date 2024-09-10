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
local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local shopPageManager = ClientSherlock:find({"PageManager", "Shop"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Money_1Page"})
local DevProductProto = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="DevProductProto"})
local DevProductContainer = DevProductProto.Parent
DevProductProto.Parent = nil

local View = {}
View.__index = View
View.className = "Money_1View"
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

local binderPlayerGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerGameState"})
local playerGameState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerGameState, inst=localPlayer})

function View:updateWithRobloxData()
    local maid = Maid.new()

    local function update(state)
        local ProductsData = Data.Shop.ShopProducts.products.Money_1
        for id, data in pairs(ProductsData) do
            local stateData = state[id]
            if not stateData then continue end

            local _gui = DevProductContainer:FindFirstChild(id)
            if not _gui then continue end

            local productTexts = _gui.Btn.ProductTexts
            productTexts.Price.Amount.Text = ("%s"):format(stateData.priceInRobux)

            -- if data.extraMoney then
            --     TableUtils.setInstance(productTexts.ExtraMoney.TextLabel, {Text = ("(+ %s for Free)"):format(NumberFormatter.numberToEng(math.ceil(data.extraMoney)))})
            --     TableUtils.setInstance(productTexts.SavedRobux.TextLabel, {Text = ("Save %.0f Robux"):format(data.savedRobux)})
            -- end
        end
    end
    maid:Add(playerGameState:getEvent(S.Session, "DevProducts", "addDevProduct"):Connect(update))
    update(playerGameState:get(S.Session, "DevProducts"))

    return maid
end

function View:updateMultipliers()
    local maid = Maid.new()
    local playerState = self.controller.playerState

    local function update()
        local ProductsData = Data.Shop.ShopProducts.products.Money_1
        local typeEarned = S.Money_1
        local sourceType = S.Money_1Packs
        for id, data in pairs(ProductsData) do
            local _gui = DevProductContainer:FindFirstChild(id)
            if not _gui then continue end
            local value = Calculators.calculate(playerState, typeEarned, data.baseValue, sourceType)
            local productTexts = _gui.Btn.ProductTexts
            productTexts.ShortDescription.TextLabel.Text = ("+%s %s"):format(
                NumberFormatter.numberToEng(value),
                Data.Money.Money[S.Money_1].prettyName
            )
        end
    end
    maid:Add(playerState:getEvent("Session", "Multipliers", "updateMultiplier"):Connect(update))
    update()

    return maid
end

local CodeF = script:FindFirstAncestor("Code")
local ShopGuiUtils = require(ComposedKey.getAsync(CodeF, {"Utils", "ShopGuiUtils"}))
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)

local ShopItemUx = require(ReplicatedStorage.Ux.ShopItem)
function View:setGuis()
    local maid = Maid.new()

    local ProductsData = Data.Shop.ShopProducts.products.Money_1
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

        maid:Add(self.controller:purchaseProduct(btn, id))
        ShopItemUx.addUx(btn, nil, data)

        _gui.LayoutOrder = data.LayoutOrder
        _gui.Name = id
        _gui.Visible = true
        _gui.Parent = DevProductContainer
    end

    maid:Add(self:updateMultipliers())
    maid:Add(self:updateWithRobloxData())

    return maid
end

shopPageManager:addGui(TabPage)
local ViewUtils = Mod:find({"Gui", "ViewUtils"})
function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(self:setGuis())
    maid:Add2(ViewUtils.open(self, TabPage, shopPageManager))
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