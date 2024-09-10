local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GpData = Data.GamePasses.GamePasses
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Promise = Mod:find({"Promise", "Promise"})

local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local RootF = script.Parent
local Utils = require(RootF.Utils)

local BigNotificationGuiRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "BigNotificationGui"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

GaiaServer.createRemotes(ReplicatedStorage, {
    events = {"PurchaseGp"}
})

GaiaShared.createBindables(ReplicatedStorage, {
    events = {"PurchaseGp"},
})
local PurchaseGpSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="PurchaseGp"})

local function gamepassPurchaseFinished(player, gpId, wasPurchased)
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end

    do
        local action = {
            name = "setPurchaseState",
            value = false,
        }
        playerState:set(S.Session, "Gui", action)
    end
    if not wasPurchased then return end

    do
        local action = {
            name="addGamePass",
            id=tostring(gpId)
        }
        playerState:set(S.Stores, "GamePasses", action)
    end
    do
        local action = {
            name="enableGamepass",
            id=tostring(gpId)
        }
        playerState:set(S.Stores, "GamePasses", action)
    end

    task.defer(function()
        local plr = player
        local binderPlayerRobuxStats = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerRobuxStats"})
        local playerRobuxStats = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerRobuxStats, inst=plr})
        if not playerRobuxStats then return end
        playerRobuxStats.UpdateRobuxStatsSE:Fire("GamePass", gpId)
    end)
end
MarketplaceService.PromptGamePassPurchaseFinished:Connect(gamepassPurchaseFinished)

local PurchaseGpRE = ReplicatedStorage.Remotes.Events.PurchaseGp
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
local function purchaseCallback(player, gpId)
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end

    if RunService:IsStudio() and game.PlaceId == 0 and Data.Studio.Studio.gps.giveGpsForFreeOnPurchase then
        do
            local action = {
                name="addGamePass",
                id=tostring(gpId)
            }
            playerState:set(S.Stores, "GamePasses", action)
        end
        do
            local action = {
                name="enableGamepass",
                id=tostring(gpId)
            }
            playerState:set(S.Stores, "GamePasses", action)
        end
    else
        Utils.doesPlayerHasGamePass(playerState, gpId)
            :andThen(function(hasPass)
                if hasPass then
                    NotificationStreamRE:FireClient(player, {
                        Text = "You already own this gamepass.",
                    })
                else
                    do
                        local action = {
                            name = "setPurchaseState",
                            value = true,
                        }
                        playerState:set(S.Session, "Gui", action)
                    end
                    MarketplaceService:PromptGamePassPurchase(player, gpId)
                end
            end)
    end
end
PurchaseGpRE.OnServerEvent:Connect(purchaseCallback)
PurchaseGpSE:Connect(purchaseCallback)

local Parent = script.Parent
local Class = require(Parent:WaitForChild(Parent.Name))

return Class