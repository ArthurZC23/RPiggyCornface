local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RootFolder = script:FindFirstAncestor("DataStore")
local SS = RootFolder.SS
local DSMonitor = require(SS.DSMonitor)
local Validation = require(SS.DevProductRequestValidation)

local TryDeveloperPurchaseRE = ReplicatedStorage.Remotes.Events:WaitForChild("TryDeveloperPurchase")

local TryDeveloperPurchaseBE = ServerStorage.Bindables.Events:WaitForChild("TryDeveloperPurchase")

local function promptPurchase(player, productId)
    MarketplaceService:PromptProductPurchase(player, productId)
end

local safePurchase = DSMonitor.checkIfStateIsBackup(
    DSMonitor.checkIfDSSIsWorking(Validation.validateRequest(promptPurchase)))

TryDeveloperPurchaseRE.OnServerEvent:Connect(safePurchase)
TryDeveloperPurchaseBE.Event:Connect(safePurchase)

local module = {}

return module
