local RunService = game:GetService("RunService")

local Data =script:FindFirstAncestor("Data")
local TimeUnits = require(Data.Date.TimeUnits)

local saveOnPurchaseHistoryAll = 1 * TimeUnits.minute -- This should be done fast
local saveOnPurchaseHistoryNewest = 2 * TimeUnits.minute -- Avoid stacks. Most probably this will without using DS.
if RunService:IsStudio() then
    -- saveOnPurchaseHistoryAll = 10
    -- saveOnPurchaseHistoryNewest = 30
end


local module = {}

module.cooldowns = {
    saveOnPurchaseHistoryAll = saveOnPurchaseHistoryAll,
    saveOnPurchaseHistoryNewest = saveOnPurchaseHistoryNewest
}


return module