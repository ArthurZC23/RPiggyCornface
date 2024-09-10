local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local MoneyLimit = Data.Money.MoneyLimit
local S = Data.Strings.Strings
local Cronos = Mod:find({"Cronos", "Cronos"})
local SuperUsers = Data.Players.Roles.HiddenRoles.HiddenRoles.SuperUsers
local DeveloperProductsData = Data.DataStore.DeveloperProducts
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
local Promise = Mod:find({"Promise", "Promise"})

-- This halts the program because of ordering
-- local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
-- local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})


local module = {}


local validations = {

}

local function validationGuard()
    -- if not production cannot buy
    -- cannot purchase anything except for donations during alpha
end

local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local PrettyNames = Data.Strings.PrettyNames
local function validateMoneyPurchase(playerState, productData)
    if playerState.isDestroyed then return end

    local baseValue = productData.baseValue
    local moneyType = productData.moneyType
    local sourceType = productData.sourceType
    local value = Calculators.calculate(playerState, moneyType, baseValue, sourceType)

    local moneyState = playerState:get(S.Stores, moneyType)
    local currentMoney = moneyState.current

    local moneyLimit = MoneyLimit[moneyType]
    if currentMoney >= moneyLimit then
        NotificationStreamRE:FireClient(playerState.player, {
            Text = ("Max %s is %s!"):format(PrettyNames[moneyType], NumberFormatter.numberToEng(moneyLimit)),
        })
        return false
    end
    return true
end

local function validateLifePurchase(playerState, productData)
    if playerState.isDestroyed then return end

    local liveState = playerState:get(S.Session, "Lives")
    if liveState.cur >= Data.Map.Map.maxLives then
        NotificationStreamRE:FireClient(playerState.player, {
            Text = "Max number of lives!",
        })
        return false
    end

    return true
end

local function validateSpinsPurchase(playerState, productData)
    if playerState.isDestroyed then return end

    local policyState = playerState:get(S.Session, "PolicyService")
    if policyState.current.ArePaidRandomItemsRestricted then
        NotificationStreamRE:FireClient(playerState.player, {
            Text = "Paid random items are restricted in your region.",
        })
        return false
    end

    return true
end

for id, productData in pairs(DeveloperProductsData) do
    if productData.type_ == "MoneyPurchase" then
        validations[id] = function(playerState)
            return validateMoneyPurchase(playerState, productData)
        end
    elseif productData.type_ == "LifePurchase" then
        validations[id] = function(playerState)
            return validateLifePurchase(playerState, productData)
        end
    elseif productData.type_ == "SpinWheel" then
        validations[id] = function(playerState)
            return validateSpinsPurchase(playerState, productData)
        end
    end
end

local function defaultValidation()
    return true
end

function module.validateRequest(func)
    return function(player, productId)
        --print(typeof(productId), productId)
        local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
        if not playerState then return false end

        local validator = validations[productId] or defaultValidation
        local isRequestValid = validator(playerState, productId)
        if playerState.isDestroyed then return end
        -- Could add a message
        if not isRequestValid then return end

        local cd = 60
        -- if RunService:IsStudio() then
        --     cd = 5
        -- end
        Promise.fromEvent(
            MarketplaceService.PromptProductPurchaseFinished
        )
            :timeout(cd)
            :finally(function()
                -- print("Finish Purchase")
                local action = {
                    name = "setPurchaseState",
                    value = false,
                }
                playerState:set(S.Session, "Gui", action)
            end)
        do
            local action = {
                name = "setPurchaseState",
                value = true,
            }
            playerState:set(S.Session, "Gui", action)
        end
        func(player, productId)
    end
end

return module