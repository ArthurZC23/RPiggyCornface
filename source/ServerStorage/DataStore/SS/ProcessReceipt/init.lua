local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TimeUnits = Data.Date.TimeUnits
local ProcessReceiptData = Data.DataStore.ProcessReceipt
local PurchaseStatus = ProcessReceiptData.purchaseStatus
local ProductsData = Data.DataStore.DeveloperProducts
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local DataStoreService = require(ServerStorage.DataStoreService)
local GameAnalytics = require(ServerStorage.GameAnalytics)

local ProductHandler = require(script.ProductIdToHandlerMap)

local datastore = DataStoreService:GetDataStore(S.PurchaseHistory, "All")

local function getPurchaseStatus(player, purchaseId, playerState)
    do
    local purchasesState = playerState:get("Stores", "DevPurchases")
    local purchase = purchasesState.cache[purchaseId]
        if purchase then return purchase.status end
    end
    do
        -- Purchase History. This will consume one GetAsync for each callback.
        -- GetAsync is not used a lot, so I don't see this a problem. One purchase
        -- takes more than 6 seconds. If it fail, there is no inversion problem.
        local key = ("%s/%s"):format(player.UserId, purchaseId)
        local ok, purchase = pcall(function() return datastore:GetAsync(key) end)
        if not ok then return PurchaseStatus.Unknown end
        if purchase then
            return PurchaseStatus.SavedOnPurchaseHistory
        else
            return PurchaseStatus.NotStarted
        end
    end
end

local function executePurchase(player, playerState, receiptInfo, purchaseId, productId)
    local productData = ProductsData[productId]

    do
        local action = {
            name = "setPurchaseCache",
            id = purchaseId,
            data = {
                status = PurchaseStatus.Started,
                productId = productId,
                datetime = Cronos:getTime(), --Less memory than ISO
            }
        }
        playerState:set("Stores", "DevPurchases", action)
    end

    -- Pure function. Cannot depend on the state of the game or player because I don't have any guarantee when the function will actually run.
    -- Just change a state, no need to save data
    -- Can yield
	local handler = ProductHandler[productId]
    do
        local ok, err = pcall(handler, receiptInfo, player, playerState, productData, purchaseId)
        if not ok then
            warn(err)
            ErrorReport.report("", err, "critical")
        end
    end

    do
        local purchasesState = playerState:get("Stores", "DevPurchases")
        local data = purchasesState.cache[purchaseId]
        data.status = PurchaseStatus.FinishedButNotSaved
        local action = {
            name = "setPurchaseCache",
            id = purchaseId,
            data = data,
        }
        playerState:set("Stores", "DevPurchases", action)
    end
end

local function processReceipt(receiptInfo)
    --print("PROCESS RECEIPT")
    local playerId = receiptInfo.PlayerId
    local purchaseId = receiptInfo.PurchaseId
    local productId = tostring(receiptInfo.ProductId) -- This is a number by default
    --print("Process receipt: ", purchaseId)
    --print("Product Id: ", productId, typeof(productId))

    local player = Players:GetPlayerByUserId(playerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

    local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then
        local message = "Player State was not found during process receipt!"
        ErrorReport.report(receiptInfo.PlayerId, message, "warning")
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    do
        local purchaseStatus = getPurchaseStatus(player, purchaseId, playerState)
            if
                purchaseStatus == PurchaseStatus.Started
                or purchaseStatus == PurchaseStatus.FinishedButNotSaved
                or purchaseStatus == PurchaseStatus.Unknown
            then
            -- Only run once per server. Don't run and don't finish in case cannot get data from PurchaseHistory.
            
            --------Never tested this part--------------
            -- if purchaseStatus == PurchaseStatus.Started then
            --     local purchasesState = playerState:get("Stores", "DevPurchases")
            --     if
            --         (not purchasesState.cache[purchaseId].datetime)
            --         or (Cronos:getTime() - purchasesState.cache[purchaseId].datetime) > 0.5 * TimeUnits.day
            --     then
            --             local data = {}
            --             data.status = PurchaseStatus.NotStarted
            --             local action = {
            --                 name = "NotStarted",
            --                 id = purchaseId,
            --                 data = data,
            --             }
            --             playerState:set("Stores", "DevPurchases", action)
            --     end
            -- end
            return Enum.ProductPurchaseDecision.NotProcessedYet

        elseif purchaseStatus == PurchaseStatus.SavedOnCache then
            pcall(function()
                GameAnalytics:ProcessReceiptCallback(receiptInfo)
            end)

            do
                local data = playerState:get("Stores", "DevPurchases").cache[purchaseId]
                data.status = PurchaseStatus.PurchaseGranted
                local action = {
                    name = "setPurchaseCache",
                    id = purchaseId,
                    data = data,
                }
                playerState:set("Stores", "DevPurchases", action)
            end

            task.defer(function()
                local plr = player
                local binderPlayerRobuxStats = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerRobuxStats"})
                local playerRobuxStats = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerRobuxStats, inst=plr})
                if not playerRobuxStats then return end
                playerRobuxStats.UpdateRobuxStatsSE:Fire("DevProduct", productId)
            end)
            --print("Purchase Granted")
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif
            purchaseStatus == PurchaseStatus.PurchaseGranted
            or purchaseStatus == PurchaseStatus.SavedOnPurchaseHistory
        then
            task.defer(function()
                local plr = player
                local binderPlayerRobuxStats = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerRobuxStats"})
                local playerRobuxStats = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerRobuxStats, inst=plr})
                if not playerRobuxStats then return end
                playerRobuxStats.UpdateRobuxStatsSE:Fire("DevProduct", productId)
            end)
            --print("Purchase Granted")
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end

    executePurchase(player, playerState, receiptInfo, purchaseId, productId)

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = processReceipt

local module = {}

return module