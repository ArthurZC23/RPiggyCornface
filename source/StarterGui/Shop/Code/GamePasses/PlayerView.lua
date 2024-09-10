local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local GridLayout = Mod:find({"Gui", "GridLayout"})

local CodeF = script:FindFirstAncestor("Code")
local ShopGuiUtils = require(ComposedKey.getAsync(CodeF, {"Utils", "ShopGuiUtils"}))

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local shopPageManager = ClientSherlock:find({"PageManager", "Shop"})

local binderPlayerGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerGameState"})
local playerGameState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerGameState, inst=localPlayer})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GamePassesPage"})
local GpProto = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="GpProto"})
local GpContainer = GpProto.Parent
GpProto.Parent = nil

local View = {}
View.__index = View
View.className = "GamePassesView"
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

    GridLayout.new(GpContainer, {
        CellPadding = UDim2.new(0, 0, 0, 0),
        CellSize = UDim2.new(0.20, 0, 0.49, 0),
        scroll = {
            scrollDirection = "Vertical",
        }
    })

    return self
end

local ShopItemUx = require(ReplicatedStorage.Ux.ShopItem)
function View:setGuis()
    local maid = Maid.new()

    local GpsUiData = Data.GamePasses.Ui
    for _, data in pairs(GpsUiData.gpProducts) do
        local gpId = data.id
        local _gui = maid:Add(GpProto:Clone())
        _gui:SetAttribute(gpId)
        local btn = _gui.Btn

        local ProductImage = btn.ProductImage
        ProductImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
        local ProductTexts = btn.ProductTexts
        -- TableUtils.setInstance(ProductTexts.Price.ImageLabel, data.robuxIcon)

        maid:Add(ShopGuiUtils.purchaseGamePass(self, _gui, gpId))
        ShopItemUx.addUx(btn, nil, data)

        _gui.LayoutOrder = data.LayoutOrder
        _gui.Name = gpId
        _gui.Visible = true
        _gui.Parent = GpContainer
    end

    local playerState = self.controller.playerState
    maid:Add(playerState:getEvent("Stores", "GamePasses", "addGamePass"):Connect(function(state, action)
        self:updateViewAfterPurchase(state, action.id)
    end))
    local gpsState = playerState:get("Stores", "GamePasses")
    for gpId in pairs(gpsState) do
        self:updateViewAfterPurchase(gpsState, gpId)
    end
    maid:Add(self:updateWithRobloxData())

    return maid
end

function View:updateViewAfterPurchase(state, gpId)
    local _gui = GpContainer:FindFirstChild(gpId)
    if not _gui then return end

    local btn = _gui.Btn

    local productTexts = btn.ProductTexts
    local Price = productTexts.Price
    local Purchased = productTexts.Purchased
    Price.Visible = (state[gpId] == nil)
    Purchased.Visible = not Price.Visible
end

function View:updateWithRobloxData()
    local maid = Maid.new()

    local function update(state)
        for _, productGui in ipairs(GpContainer:GetChildren()) do
            if (not productGui:IsA("GuiObject")) or (not productGui.Visible) then continue end
            local gpId = productGui.Name
            local stateData = state[gpId]
            if not stateData then continue end

            local btn = productGui.Btn
            local ProductImage = btn.ProductImage

            ProductImage.Image = stateData.thumbnail

            local productTexts = btn.ProductTexts
            productTexts.Price.Amount.Text = ("%s"):format(stateData.priceInRobux)
            productTexts.ShortDescription.TextLabel.Text = stateData.prettyName
        end
    end
    maid:Add(playerGameState:getEvent("Session", "GamePasses", "addGamePass"):Connect(update))
    update(playerGameState:get("Session", "GamePasses"))

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