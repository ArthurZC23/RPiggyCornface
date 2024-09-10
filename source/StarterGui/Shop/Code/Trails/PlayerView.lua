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

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local ViewUtils = Mod:find({"Gui", "ViewUtils"})

local EzRefUtils = Mod:find({"EzRef", "Utils"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="TrailsPage"})
local TrailProto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="TrailProto"})
local TrailContainer = TrailProto.Parent
EzRefUtils.runEzRef(TrailProto)

local shopPageManager = ClientSherlock:find({"PageManager", "Shop"})
shopPageManager:addGui(TabPage)

TrailProto.Parent = nil

local View = {}
View.__index = View
View.className = "TrailsView"
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

    GridLayout.new(TrailContainer, {
        CellPadding = UDim2.new(0, 0, 0, 0),
        CellSize = UDim2.new(0.40, 0, 0.40, 0),
        scroll = {
            scrollDirection = "Vertical",
        }
    })

    return self
end

local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local PrettyNames = Data.Strings.PrettyNames
function View:setFinishChapterReward(id, _gui, shopData)
    local TrailPrice = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="TrailPrice"})
    TrailPrice.Text = ("%s %s"):format(NumberFormatter.numberToEng(shopData.price), PrettyNames[S.FinishChapter])
end

function View:setGamepassReward(id, _gui, shopData)
    local gpData = Data.GamePasses.GamePasses.idToData[shopData.gpId]
    local TrailPrice = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="TrailPrice"})
    TrailPrice.Text = ("%s"):format(gpData.prettyName)
end

function View:createTrailsGui()
    local maid = Maid.new()
    local trailsData = Data.Trails.Trails.idData
    local playerState = self.controller.playerState
    for id, data in pairs(trailsData) do
        if data.gridView == false then continue end
        local _gui = maid:Add(TrailProto:Clone())
        _gui.Name = ("%s"):format(id)
        _gui.LayoutOrder = data.ui.LayoutOrder
        _gui.Parent = TrailContainer
    end

    local function updateButtons(state, action)
        local id = action.id
        if not id then return end
        local _gui = TrailContainer:FindFirstChild(id)
        if not _gui then return end
        local trailData = Data.Trails.Trails.idData[id]
        local shopData = trailData.rewards.shop

        local maidButtons = self._maid:Add2(Maid.new(), ("ButtonsTrail%s"):format(id))

        local BuyBtn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="BuyBtn"})
        local EquipBtn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="EquipBtn"})
        local UnequipBtn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="UnequipBtn"})
        BuyBtn.Visible = false
        EquipBtn.Visible = false
        UnequipBtn.Visible = false

        if state.st[id] == nil then
            if shopData._type == "Gamepass" then
                BuyBtn.Visible = true
                local Btn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=BuyBtn, refName="Btn"})
                maidButtons:Add(self.controller:buyGp(Btn, shopData.gpId))
            end
        elseif state.eq == id then
            UnequipBtn.Visible = true
            local Btn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=UnequipBtn, refName="Btn"})
            maidButtons:Add(self.controller:unequipTrail(Btn, id))
        else
            EquipBtn.Visible = true
            local Btn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=EquipBtn, refName="Btn"})
            maidButtons:Add(self.controller:equipTrail(Btn, id))
        end
    end

    local function updatePrice(state, action)
        local id = action.id
        local _gui = TrailContainer:FindFirstChild(id)
        if not _gui then return end
        local TrailPrice = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="TrailPrice"})
        if not TrailPrice then return end
        local data = Data.Trails.Trails.idData[id]
        TrailPrice.Text = ""
        if state.st[id] then
            -- TrailPrice.Text = ""
        else
            local shopData = data.rewards.shop
            if shopData._type == "Gamepass"  then
                self:setGamepassReward(id, _gui, shopData)
            elseif shopData._type == S.FinishChapter  then
                self:setFinishChapterReward(id, _gui, shopData)
            end
        end
    end

    self._maid:Add(playerState:getEvent(S.Stores, "Trails", "add"):Connect(function(state, action)
        updatePrice(state, action)
        updateButtons(state, action)
    end))
    self._maid:Add(playerState:getEvent(S.Stores, "Trails", "unequip"):Connect(updateButtons))
    self._maid:Add(playerState:getEvent(S.Stores, "Trails", "equip"):Connect(updateButtons))


    for id, data in pairs(trailsData) do
        local _gui = TrailContainer:FindFirstChild(id)
        if not _gui then continue end

        local TrailName = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="TrailName"})
        local TrailBackground = SharedSherlock:find({"EzRef", "GetSync"}, {inst=_gui, refName="TrailBackground"})

        TrailName.Text = data.prettyName
        local singleColor = data.ui.color
        if singleColor then
            TrailBackground.ImageColor3 = singleColor
            TrailBackground.UIGradient:Destroy()
        else
            TrailBackground.ImageColor3 = Color3.fromRGB(255, 255, 255)
            TrailBackground.UIGradient.Enabled = true
            TrailBackground.UIGradient.Color = data.trailProps.Color
        end

        local trailState = playerState:get(S.Stores, "Trails")
        updatePrice(trailState, {
            id = id,
        })
        updateButtons(trailState, {
            id = id,
        })

        _gui.Visible = true
    end

    return maid
end

function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(self:createTrailsGui())
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