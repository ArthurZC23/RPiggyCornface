local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local DeveloperProducts = Data.DataStore.DeveloperProducts
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

return function ()
    for id in pairs(DeveloperProducts) do
        Promise.try(function ()
            local ok, productInfo = pcall(function()
                return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
            end)
            if not ok then
                local err = productInfo
                error(("Failed to GetProductInfo for %s.\n%s"):format(id, err))
            end
            local action = {
                name = "addDevProduct",
                id = id,
                data = {priceInRobux = productInfo.PriceInRobux}
            }
            gameState:set("Session", "DevProducts", action)
        end)
            :catch(function (err)
                warn(tostring(err))
            end)
            :await()
    end
end