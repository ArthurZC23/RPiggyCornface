local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = script:FindFirstAncestor("Data")
local DeveloperProducts = require(Data.DataStore.DeveloperProducts)
local PrettyNames = require(Data.Strings.PrettyNames)

local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)

local module = {}

local COLORS = {
    MAIN = Color3.fromRGB(248, 255, 115),
}

local size0 = 0.25
local step = 0.11

local name = "Money_1"
local prettyName = PrettyNames[name]
module = {
    thumbnail = {
        Image="rbxassetid://6543591915",
        ImageColor3=Color3.fromRGB(255, 255, 255)
    },
    name = name,
    prettyName = prettyName,
    color = COLORS.MAIN,
    developerProducts = {
        ["1353963949"] = {
            thumbnail = {
                Image="rbxassetid://6543592310",
                -- Size = UDim2.fromScale(size0, size0),
            },
            idx = 1,
        },
        ["1353964005"] = {
            thumbnail = {
                Image="rbxassetid://6543592310",
                -- Image="rbxassetid://6543592733",
                -- Size = UDim2.fromScale(size0, size0),
            },
            idx = 2,
        },
        ["1353964055"] = {
            thumbnail = {
                Image="rbxassetid://6543592733",
                -- Image="rbxassetid://6543760931",
                -- Size = UDim2.fromScale(size0, size0),
            },
            idx = 3,
        },
        ["1353964109"] = {
            thumbnail = {
                Image="rbxassetid://6543592733",
                -- Image="rbxassetid://6543761181",
                -- Size = UDim2.fromScale(size0, size0),
            },
            idx = 4,
        },
        ["1353964163"] = {
            thumbnail = {
                Image="rbxassetid://6543760931",
                -- Image="rbxassetid://6543761412",
                -- Size = UDim2.fromScale(size0, size0),
            },
            idx = 5,
        },
        ["1353964258"] = {
            thumbnail = {
                Image="rbxassetid://6543592733",
                -- Image="rbxassetid://6543761632",
                -- Size = UDim2.fromScale(size0, size0),
            },
            idx = 6,
        },
    },
}

-- local devProduct_1 = DeveloperProducts["1353963949"]
-- local baseRatio = devProduct_1.baseValue / devProduct_1.price

-- for productId, localDevData in pairs(module.developerProducts) do
--     localDevData.id = productId
--     TableUtils.setProto(localDevData, {
--         thumbnail = {
--             ImageColor3 = Color3.fromRGB(255, 255, 255),
--         },
--         shortDescription = {
--             TextColor3=Color3.fromRGB(255, 255, 255),
--         },
--         longDescription={
--             TextColor3=COLORS.MAIN,
--             TextStrokeColor3 = Color3.new(0, 0, 0),
--             TextStrokeTransparency = 0.5,
--         },
--         colors = {
--             --default=Color3.fromRGB(6, 131, 44),
--             default=Color3.fromRGB(200, 200, 200),
--             hover=Color3.fromRGB(21, 214, 47)
--         },
--         priceInRobux = {
--             TextColor3=Color3.fromRGB(255, 255, 255),
--             TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
--             TextStrokeTransparency = 0,
--         },
--     })

--     local serverData = DeveloperProducts[productId]
--     local data = module.developerProducts[productId]
--     data.LayoutOrder = localDevData.idx
--     data.name = serverData.name
--     data.baseValue = serverData.baseValue
--     data.boost = serverData.boost

--     if serverData.packNum > 3 then
--         local fairMoneyValue = serverData.price * baseRatio
--         data.extraMoney = data.baseValue - fairMoneyValue
--         data.savedRobux = data.extraMoney / baseRatio
--     end
-- end

return module