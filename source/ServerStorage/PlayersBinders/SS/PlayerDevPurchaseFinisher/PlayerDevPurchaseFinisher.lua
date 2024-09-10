local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local ProcessReceiptData = Data.DataStore.ProcessReceipt
local PurchaseStatus = ProcessReceiptData.purchaseStatus

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local PlayerDevPurchaseFinisher = {}
PlayerDevPurchaseFinisher.__index = PlayerDevPurchaseFinisher
PlayerDevPurchaseFinisher.className = "PlayerDevPurchaseFinisher"
PlayerDevPurchaseFinisher.TAG_NAME = PlayerDevPurchaseFinisher.className

function PlayerDevPurchaseFinisher.new(player)
    local self = {}
    setmetatable(self, PlayerDevPurchaseFinisher)
    self._maid = Maid.new()
    self.player = player
    self.notSavedPurchases = {}
    FastSpawn(function()
        local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
        if not playerState then return end

        self:updateArray(playerState)

        -- This wiil not run when player leaves. However, this is not a problem.
        playerState.afterSaveSignal:Connect(function()
            self:updatePurchasesStatus(playerState)
            self.notSavedPurchases = {}
        end)
    end)

    return
end

function PlayerDevPurchaseFinisher:updateArray(playerState)
    playerState:getEvent("Stores", "DevPurchases", "setPurchaseCache"):Connect(function(state, action)
        local data = state.cache[action.id]
        if data.status == PurchaseStatus.FinishedButNotSaved then
            table.insert(self.notSavedPurchases, action.id)
        end
    end)

    for id, data in pairs(playerState:get("Stores", "DevPurchases").cache) do
        if data.status == PurchaseStatus.FinishedButNotSaved then
            table.insert(self.notSavedPurchases, id)
        end
    end
end

function PlayerDevPurchaseFinisher:updatePurchasesStatus(playerState)
    local purchasesState = playerState:get("Stores", "DevPurchases")
    for i, purchaseId in ipairs(self.notSavedPurchases) do
        local data = purchasesState.cache[purchaseId]
        if not data then
            table.remove(self.notSavedPurchases, i)
            continue
        end
        -- attempt to index nil with status.
        data.status = PurchaseStatus.SavedOnCache
        local action = {
            name = "setPurchaseCache",
            id = purchaseId,
            data = data,
        }
        playerState:set("Stores", "DevPurchases", action)
    end
end

function PlayerDevPurchaseFinisher:Destroy()
    self._maid:Destroy()
end

return PlayerDevPurchaseFinisher