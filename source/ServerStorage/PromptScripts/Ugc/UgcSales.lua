local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)

for i, ugcId in ipairs({14756796379, 14783574934, 14840705013, 14938135008, 15016355474, 15040415080, 15082030743, 15082026257}) do
    local data = MarketplaceService:GetProductInfo(ugcId, Enum.InfoType.Asset)
    print("-----------------------------")
    print(data.Name, data.Sales)
end