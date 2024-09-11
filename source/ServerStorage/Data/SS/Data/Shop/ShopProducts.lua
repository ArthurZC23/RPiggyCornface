local Data = script:FindFirstAncestor("Data")
local DeveloperProducts = require(Data.DataStore.DeveloperProducts)

local module = {}

module.products = {}

module.products.Money_1 = {
    -- ["1888470122"] = {
    --     thumbnail = "rbxassetid://6543591915",
    --     LayoutOrder = 1,
    -- },
    -- ["1888470294"] = {
    --     thumbnail = "rbxassetid://6543591915",
    --     LayoutOrder = 2,
    -- },
    -- ["1888470511"] = {
    --     thumbnail = "rbxassetid://6543591915",
    --     LayoutOrder = 3,
    -- },
    -- ["1888470650"] = {
    --     thumbnail = "rbxassetid://6543591915",
    --     LayoutOrder = 4,
    -- },
    -- ["1888470783"] = {
    --     thumbnail = "rbxassetid://6543591915",
    --     LayoutOrder = 5,
    -- },
}

for productId, data in pairs(module.products.Money_1) do
    local devProductData = DeveloperProducts[productId]
    data.baseValue = devProductData.baseValue
end

return module