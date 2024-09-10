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
local Debounce = Mod:find({"Debounce", "Debounce"})

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GameProto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GameProto"})
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local Container = GameProto.Parent
GameProto.Parent = nil

local View = {}
View.__index = View
View.className = "OtherGamesGridView"
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

    GridLayout.new(Container, {
        CellPadding = UDim2.new(0, 0, 0, 0),
        CellSize = UDim2.new(0.40, 0, 0.40, 0),
        scroll = {
            scrollDirection = "Vertical",
        }
    })

    return self
end

local MarketplaceService = game:GetService("MarketplaceService")
local function getGameIcon(gameData)
    return function()
        return Promise.new(function(resolve, reject)
            local ok, gameIcon = pcall(function()
                local gameDataMkt = MarketplaceService:GetProductInfo(gameData.PRODUCTION.placeId)
                return gameDataMkt.IconImageAssetId
            end)
            if ok then
                resolve(gameIcon)
            else
                local err = gameIcon
                reject(err)
            end
        end)
    end
end
function View:createGui()
    local maid = Maid.new()
    for gameName, data in pairs(Data.Game.Game.otherGames) do
        if not data.view then continue end
        local _gui = maid:Add(GameProto:Clone())
        _gui.Name = ("%s"):format(gameName)
        local btn = _gui.Btn
        local imageLabel = btn.ImageLabel
        local AssetName = imageLabel.AssetName
        AssetName.TextLabel.Text = data.viewName

        if data.thumbnail then
            imageLabel.Image = data.thumbnail
        else
            Promise.retryWithDelay(getGameIcon(data), 3, 10)
            :andThen(function(gameIcon)
                imageLabel.Image = ("rbxassetid://%s"):format(gameIcon)
            end)
        end

        _gui.LayoutOrder = data.LayoutOrder

        self.controller:teleportToGame(btn, gameName)
        _gui.Visible = true
        _gui.Parent = Container
    end
    return maid
end

function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add2(function()
        pageManager:close(GuiFrame, false)
    end)
    maid:Add(self:createGui())
    pageManager:open(GuiFrame, false)
end

function View:close()
    self._maid:Remove("Open")
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