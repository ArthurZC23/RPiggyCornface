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
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
local GuiClasses = Mod:find({"Gui", "GuiClasses"})
local GridLayout = require(GuiClasses.Layout.Grid.Grid)
local AssetsUtils = Mod:find({"Assets", "Shared", "Utils"})

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local SkinProto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="SkinProto"})
local SkinContainer = SkinProto.Parent
SkinProto.Parent = nil

local View = {}
View.__index = View
View.className = "ItemShopView"
View.TAG_NAME = View.className

local function setAttributes()
    script:SetAttribute("VipColor", Color3.fromRGB(170, 170, 0))
end
setAttributes()

function View.new(controller)
    local self = {
        _maid = Maid.new(),
        controller = controller,
    }
    setmetatable(self, View)
    if not self:getFields() then return end

    GridLayout.new(SkinContainer, {
        CellPadding = UDim2.new(0, 0, 0, 0),
        CellSize = UDim2.new(0.5, 0, 0.5, 0),
        scroll = {
            scrollDirection = "Vertical",
        }
    })

    return self
end

local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function View:setPrice(morphId, _gui, data, shopData)
    local maid = Maid.new()

    local Price = _gui.Price
    Price.Size = UDim2.fromScale(0.5, 0.2)
    Price.Price.Size = UDim2.fromScale(0.65, 1)

    if shopData._type == "Money" then
        local moneyType = shopData.moneyType
        local MoneyData = Data.Money.Money
        Price.ImageLabel.Image = MoneyData[moneyType].thumbnail
        -- Price.Price.Size = UDim2.fromScale(0.30, 0.15)
        Price.Price.Text = NumberFormatter.numberToEng(shopData.price)
        Price.Visible = true
    end

    return maid
end

function View:createGridGui()
    local maid = Maid.new()
    local function update()
        local maidGrid = maid:Add2(Maid.new(), "Grid")
        for id, data in pairs(Data.Items.Items.idData) do
            if data.gridView == false then continue end
            local _gui = maidGrid:Add(SkinProto:Clone())
            _gui.Name = ("%s"):format(id)
            local btn = _gui.Btn
            local Vpf = btn.Vpf

            _gui.Message.Visible = true
            _gui.Message.Size = UDim2.fromScale(1, 0.15)
            _gui.Message.TextLabel.Text = data.viewName

            AssetsUtils.setModel(Vpf, "Item", {
                id = id,
                cameraProps = data.vpf,
                WorldModel = Vpf.WorldModel
            })
            _gui.LayoutOrder = data.LayoutOrder
            if data.rewards.shop then
                maidGrid:Add(self:setPrice(id, _gui, data, data.rewards.shop))
            end
            maidGrid:Add(self.controller:buyItem(btn, id))
            _gui.Visible = true
            _gui.Parent = SkinContainer
        end
    end
    update()

    return maid
end

local ViewUtils = Mod:find({"Gui", "ViewUtils"})
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})
function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(self:createGridGui())
    maid:Add2(ViewUtils.open(self, GuiFrame, pageManager))
end

function View:close()
    ViewUtils.close(self)
end

local BinderUtils = Mod:find({"Binder", "Utils"})
function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerGuis", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

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