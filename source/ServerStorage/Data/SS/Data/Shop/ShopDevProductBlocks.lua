local Data = script:FindFirstAncestor("Data")
local DeveloperProducts = require(Data.DataStore.DeveloperProducts)

local module = {}
module.idData = {}

for devProductId, data in pairs(DeveloperProducts) do
    if data.moneyType then
        module.idData[devProductId] = {
            baseValue = data.baseValue,
            moneyType = data.moneyType,
            sourceType = data.sourceType,
            price = data.price,
        }
    end
end

return module