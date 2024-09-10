local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer
local PlayerGui  = localPlayer:WaitForChild("PlayerGui")

local TryDeveloperPurchaseRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "TryDeveloperPurchase"})
local BoostsUx = require(ReplicatedStorage.Ux.Boosts)

local DonationPurchaseGuiC = {}
DonationPurchaseGuiC.__index = DonationPurchaseGuiC
DonationPurchaseGuiC.className = "DonationPurchaseGui"
DonationPurchaseGuiC.TAG_NAME = DonationPurchaseGuiC.className

function DonationPurchaseGuiC.new(gui)
    local self = {
        _maid = Maid.new(),
        gui = gui,
        ProductProto = gui.Root.Products.ProductProto,
    }
    setmetatable(self, DonationPurchaseGuiC)

    self:setGui()
    self:setHeader()
    self:addProducts()

    return self
end

function DonationPurchaseGuiC:setGui()
    self.gui.Name = "DonationPurchaseGui"
    self.gui.PixelsPerStud = 75
    self.gui.LightInfluence = 0
    self.gui.Adornee = self.gui.Parent
    self.gui.AlwaysOnTop = false
    self.gui.Enabled = true
    self.gui.ResetOnSpawn = false
    self.gui.Parent = PlayerGui
end

function DonationPurchaseGuiC:setHeader()
    self.gui.Root.Header.Text = "Donation"
    self.gui.Root.Header2.Text = "(Donations start fireworks! The bigger the donation, the longer the duration of the fireworks!)"
end

function DonationPurchaseGuiC:render(productGui, productData)
    local function update()
        productGui.LayoutOrder = productData.LayoutOrder
        local AmountTextLabel = productGui.Amount.Btn.TextLabel
        AmountTextLabel.Text = ("Donate: %s"):format(productData.baseValue)
    end
    update()
end

function DonationPurchaseGuiC:addPurchase(productGui)
    local btn = productGui
    btn.Activated:Connect(function()
        TryDeveloperPurchaseRE:FireServer(productGui.Name)
    end)

    BoostsUx.addUx(btn, {
        dilatation = {
            expandFactor = {
                X=1,
                Y=1.1,
            }
        }
    })
end

function DonationPurchaseGuiC:addProducts()
    self.ProductsContainer = self.ProductProto.Parent
    self.ProductProto.Parent = nil
    local UiData = Data.Donation.UI
    for productId, productData in pairs(UiData.developerProducts) do
        local productGui = self.ProductProto:Clone()
        productGui.Name = productId
        self:addPurchase(productGui)
        self:render(productGui, productData)
        productGui.Visible = true
        productGui.Parent = self.ProductsContainer
    end
end

function DonationPurchaseGuiC:Destroy()
    self._maid:Destroy()
end

return DonationPurchaseGuiC