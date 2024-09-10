local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Mts = Mod:find({"Table", "Mts"})

local module = {}

-- module = {
--     ["MAX_RETRIES"] = 1, -- Must be quick because player can try to use unvalidated data.
-- }

module.purchaseStatus = {
    Unknown = "Unknown", -- In case cannot get data back from DS
    NotStarted = "NotStarted",
    Started="Started", -- This is not equivalent to purchaseBeingProcessed?
    FinishedButNotSaved="FinishedButNotSaved",
    SavedOnCache="SavedOnCache",
    PurchaseGranted = "PurchaseGranted",
    SavedOnPurchaseHistory="SavedOnPurchaseHistory",
}

module.purchaseStatus = Mts.makeEnum("PurchaseStatus", module.purchaseStatus)

return module