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
View.className = "MonsterSkinsView"
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

function View:showEquipped()
    local maid = Maid.new()

    local function update(state)
        local maidUpdate = maid:Add2(Maid.new(), "update")
        local _gui = SkinContainer:FindFirstChild(state.eq)
        if not _gui then return end
        local okMarker = maidUpdate:Add2(ReplicatedStorage.Assets.Guis.OkMarker:Clone())
        okMarker.Size = UDim2.fromScale(0.5, 0.5)
        okMarker.Position = UDim2.fromScale(0, 0)
        okMarker.AnchorPoint = Vector2.new(0, 0)
        okMarker.Parent = _gui.Btn
    end
    local playerState = self.controller.playerState
    maid:Add(playerState:getEvent(S.Stores, "MonsterSkins", "eq"):Connect(update))
    local state = playerState:get(S.Stores, "MonsterSkins")
    update(state)

    return maid
end

local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function View:setSkinShopReward(morphId, _gui, data, shopData)
    local maid = Maid.new()

    local mSkinState = self.controller.playerState:get(S.Stores, "MonsterSkins")
    if mSkinState.st[morphId] then return maid end
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
    elseif shopData._type == "Group" then
        Price.ImageLabel:Destroy()
        -- Price.Price.Size = UDim2.fromScale(1, 1)
        Price.Price.TextXAlignment = Enum.TextXAlignment.Center
        Price.Price.TextYAlignment = Enum.TextYAlignment.Center
        Price.Price.Text = "Like Game & Join Group"
        Price.Visible = true
    elseif shopData._type == "Gamepass" then
        Price.ImageLabel:Destroy()
        -- Price.Price.Size = UDim2.fromScale(1, 1)
        local gpId = shopData.gpId
        local gpData = Data.GamePasses.GamePasses.idToData[gpId]
        Price.Price.TextXAlignment = Enum.TextXAlignment.Center
        Price.Price.TextYAlignment = Enum.TextYAlignment.Center
        Price.Price.Text = ("%s"):format(gpData.prettyName)
        Price.Visible = true
    end

    return maid
end

function View:shouldShowMorph(id, data, skinState)
    if next(data.rewards.shop) == nil and skinState.st[id] == nil then return false end
    return true
end

function View:createSkinGui()
    local maid = Maid.new()
    local function update()
        local maidGrid = maid:Add2(Maid.new(), "Grid")
        local playerState = self.controller.playerState
        local skinState = playerState:get(S.Stores, "MonsterSkins")
        for id, data in pairs(Data.MonsterSkins.MonsterSkins.idData) do
            if data.gridView == false then continue end
            if not self:shouldShowMorph(id, data, skinState) then continue end
            local _gui = maidGrid:Add(SkinProto:Clone())
            _gui.Name = ("%s"):format(id)
            local btn = _gui.Btn
            local Vpf = btn.Vpf

            _gui.Message.Visible = true
            _gui.Message.Size = UDim2.fromScale(1, 0.15)
            _gui.Message.TextLabel.Text = data.viewName

            AssetsUtils.setModel(Vpf, "MonsterSkin", {
                id = id,
                cameraProps = data.vpf,
                WorldModel = Vpf.WorldModel
            })
            _gui.LayoutOrder = data.LayoutOrder
            if data.rewards.shop then
                maidGrid:Add(self:setSkinShopReward(id, _gui, data, data.rewards.shop))
            end
            maidGrid:Add(self.controller:setMonsterSkin(btn, id))
            _gui.Visible = true
            _gui.Parent = SkinContainer
        end
    end
    update()

    return maid
end

function View:updateOnPurchase()
    local maid = Maid.new()
    local function update(_, action)
        local _gui = SkinContainer:FindFirstChild(action.id)
        if not _gui then return end
        local Price = _gui:FindFirstChild("Price")
        if Price then
            Price.Visible = false
        end
    end
    local playerState = self.controller.playerState
    maid:Add(playerState:getEvent(S.Stores, "MonsterSkins", "add"):Connect(update))

    return maid
end

local ViewUtils = Mod:find({"Gui", "ViewUtils"})
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="MonsterSkinPage"})
local shopPageManager = ClientSherlock:find({"PageManager", "Shop"})
shopPageManager:addGui(TabPage)
function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(self:updateOnPurchase())
    maid:Add(self:createSkinGui())
    maid:Add(self:showEquipped())
    maid:Add2(ViewUtils.open(self, TabPage, shopPageManager))
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