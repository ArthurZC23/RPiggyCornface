local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Data = Mod:find({"Data", "Data"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local PurchaseHistory = Data.DataStore.PurchaseHistory
local Cooldowns = PurchaseHistory.cooldowns
local ProductsData = Data.DataStore.DeveloperProducts
local ProcessReceiptData = Data.DataStore.ProcessReceipt
local PurchaseStatus = ProcessReceiptData.purchaseStatus
local S = Data.Strings.Strings

local DataStoreService = require(ServerStorage.DataStoreService)

local PlayerPurchaseHistory = {}
PlayerPurchaseHistory.__index = PlayerPurchaseHistory
PlayerPurchaseHistory.className = "PlayerPurchaseHistory"
PlayerPurchaseHistory.TAG_NAME = PlayerPurchaseHistory.className

-- Why I save newest and all?

function PlayerPurchaseHistory.new(player)
    local self = {}
    setmetatable(self, PlayerPurchaseHistory)
    self.player = player
    self._maid = Maid.new()

    self.newestDs = DataStoreService:GetDataStore(S.PurchaseHistory, "Newest")
    --self.allDs = DataStoreService:GetDataStore(S.PurchaseHistory, "All")

    local prom = Promise.try(function ()
        local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
        return playerState
    end)

    prom:andThen(function(playerState)
        if not playerState then return end
        local method = "saveOnPurchaseHistoryAll"
        Cronos.wait(Cooldowns[method] + Random.new():NextInteger(6, 10))
        while player.Parent do
            -- Also dummy save all casual purchases that I don't want to keep track of. E.g. increase pick chance.
            self[method](self, playerState)
            Cronos.wait(Cooldowns[method])
        end
    end)

    prom:andThen(function(playerState)
        if not playerState then return end
        local method = "saveOnPurchaseHistoryNewest"
        Cronos.wait(Cooldowns[method] + Random.new():NextInteger(6, 10))
        while player.Parent do
            self[method](self, playerState)
            Cronos.wait(Cooldowns[method])
        end
    end)

    return self
end

local function prettify(purchaseId, data)
    local datetime = DateTime.fromUnixTimestamp(data.datetime):ToIsoDate()
    local dataCopy = TableUtils.deepCopy(data)
    dataCopy.status = nil
    dataCopy.purchaseId = purchaseId
    dataCopy.productName = ProductsData[dataCopy.productId]["name"]
    dataCopy.datetime = datetime
    return dataCopy
end

local function getNextRecordToSave(cache)
    for purchaseId, data in pairs(cache) do
        if data.status == PurchaseStatus.PurchaseGranted then
            local prettyData = prettify(purchaseId, data)
            return prettyData
        end
    end
end

function PlayerPurchaseHistory:saveOnPurchaseHistoryAll(playerState)
    --print("saveOnPurchaseHistoryAll")
    local purchasesState = playerState:get("Stores", "DevPurchases")
    local prettyData = getNextRecordToSave(purchasesState.cache)
    if not prettyData then return end

    -- -- This is critical purchase.status = PurchaseStatus.SavedOnPurchaseHistory. Why here and not in the other ds?
    -- Is better to leave here to avoid messing up this critical code. Make a fake save and set the playerState.
    Promise.new(function (resolve, reject)
        -- local key = ("%s/%s"):format(self.player.UserId, prettyData.purchaseId)
        -- local ok, err = function() self.allDs:SetAsync(key, prettyData) end
        -- if ok then
        --     local purchase = purchasesState.cache[prettyData.purchaseId]
        --     purchase.status = PurchaseStatus.SavedOnPurchaseHistory
        --     local action = {
        --        name="setPurchaseCache",
        --        id = prettyData.purchaseId,
        --        data = purchase
        --     }
        --     playerState:set("Stores", "DevPurchases", action)
        --     resolve()
        -- else
        --     reject(tostring(err))
        -- end
        local purchase = purchasesState.cache[prettyData.purchaseId]
        purchase.status = PurchaseStatus.SavedOnPurchaseHistory
        local action = {
            name="setPurchaseCache",
            id = prettyData.purchaseId,
            data = purchase
        }
        playerState:set("Stores", "DevPurchases", action)
        resolve()
    end)
        :catch(function (err) ErrorReport.report(self.player.UserId, tostring(err), ErrorReport.severity.error) end)
        :await()
end

local function getSavedPurchases(purchasesState)
    local savedPurchases = {}
    for purchaseId, data in pairs(purchasesState.cache) do
        if data.status == PurchaseStatus.SavedOnPurchaseHistory then
            local prettyData = prettify(purchaseId, data)
            table.insert(savedPurchases, prettyData)
        end
    end
    -- Show new purchases first
    table.sort(savedPurchases, function(a, b)
        local dateA = DateTime.fromIsoDate(a.datetime)
        local dateB = DateTime.fromIsoDate(b.datetime)
        return dateA.UnixTimestamp > dateB.UnixTimestamp
    end)
    return savedPurchases
end

function PlayerPurchaseHistory:saveNewest(purchasesState, savedPurchases)
    local idx = purchasesState.newestIdx
    local key = ("%s/%s"):format(self.player.UserId, idx)
    local ok, purchaseHistory = pcall(
        function()
            return self.newestDs:UpdateAsync(key, function(purchaseHistory)
                purchaseHistory = purchaseHistory or {}
                -- print("-----------Before concat-----------")
                -- print("purchaseHistory")
                --TableUtils.print(purchaseHistory)
                --print("savedPurchases")
                --TableUtils.print(savedPurchases)
                purchaseHistory = TableUtils.concatArrays(savedPurchases, purchaseHistory)
                --print("-----------After concat-----------")
                --TableUtils.print(purchaseHistory)
                --print("---------------")
                return purchaseHistory
            end)
        end
    )
    return ok, purchaseHistory
end

function PlayerPurchaseHistory:updateCache(playerState, purchaseHistory)
    local sizeOfLastRecord = #purchaseHistory
    if sizeOfLastRecord >= 1e3 then
        -- update idx. No problem if save failed. 1e3 is not that big. It can grow bigger.
        local action = {
           name="updateRecordIdx",
        }
        playerState:set("Stores", "DevPurchases", action)
    end

    -- Clear records
    -- Can only clear records that were recorded lol!
    local purchases = playerState:get("Stores", "DevPurchases")
    local cache = purchases.cache
    for purchaseId, data in pairs(cache) do
        if data.status == PurchaseStatus.SavedOnPurchaseHistory then
            local action = {
                name="removeCache",
                id = purchaseId
            }
            playerState:set("Stores", "DevPurchases", action)
        end
    end
end

function PlayerPurchaseHistory:saveOnPurchaseHistoryNewest(playerState)
    --print("saveOnPurchaseHistoryNewest")
    -- need to add purchase id to data
    -- last purchases should appear first, since they're more relevant.
    local purchasesState = playerState:get("Stores", "DevPurchases")
    local savedPurchases = getSavedPurchases(purchasesState)
    if not next(savedPurchases) then return end

    Promise.new(function (resolve, reject)
        local ok, purchaseHistory = self:saveNewest(purchasesState, savedPurchases)
        if ok then
            self:updateCache(playerState, purchaseHistory)
            resolve()
        else
            local err = purchaseHistory
            reject(tostring(err))
        end
    end)
        :catch(function (err) ErrorReport.report(self.player.UserId, tostring(err), ErrorReport.severity.error) end)
        :await()
end

function PlayerPurchaseHistory:Destroy()
    self._maid:Destroy()
end

return PlayerPurchaseHistory