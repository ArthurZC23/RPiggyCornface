local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local GamePasses = Data.GamePasses.GamePasses
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

return function ()
    for i, data in pairs(GamePasses.data) do
        Promise.try(function ()
            -- print("GamePass id: ", data.id)
            local productInfo = MarketplaceService:GetProductInfo(data.id, Enum.InfoType.GamePass)
            local action = {
                name = "addGamePass",
                id = tostring(data.id),
                data = {
                    prettyName = productInfo.Name,
                    longDescription = productInfo.Description,
                    thumbnail = ("rbxassetid://%s"):format(productInfo.IconImageAssetId),
                }
            }
            if productInfo.IsForSale then
                action.data["priceInRobux"] = productInfo.PriceInRobux
            else
                action.data["priceInRobux"] = "Not for sale"
            end
            gameState:set("Session", "GamePasses", action)
        end)
            :catch(function (err)
                warn(tostring(err))
            end)
            :await()
    end
end