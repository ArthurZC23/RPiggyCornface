local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local module = {}

function module._getPlayerFunds(player, playerState, currencyType)
    local ok, state = pcall(function()
        return playerState:get("Stores", currencyType)
    end)

    if ok then
        return state.current
    end
end

function module._doesPlayerHasFunds(player, currencyType, playerFunds, totalPrice)
    if playerFunds >= totalPrice then
        return true
    else
        return false
    end
end

function module.isRequestValid(player, currencyType, totalPrice, kwargs)
    local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then return end

    local playerFunds = module._getPlayerFunds(player, playerState, currencyType)
    if not playerFunds then return end

    if not module._doesPlayerHasFunds(player, currencyType, playerFunds, totalPrice) then
        if RunService:IsClient() then
            local openBtnLikeEvent = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal=("No%s"):format(currencyType)})
            openBtnLikeEvent:Fire(true)
        end
        return
    end
    return true
end

return module