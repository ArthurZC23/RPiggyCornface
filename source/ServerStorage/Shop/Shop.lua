local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = ComposedKey("ReplicatedStorage", "Sherlocks", "Shared", "Mod")
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

local module = {}

function module._getPlayerFunds(player, playerState, currencyType)
    local ok, state = pcall(function()
        return playerState:get("Stores", currencyType)
    end)

    if ok then
        return state.current
    else
        local message = ("Player %s %s called purchase with unsupported currency type %s")
            :format(player.Name, player.UserId, currencyType)
        ErrorReport.report(player.UserId, message, "error")
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
    if currencyType == "Robux" then
       return
    end

    local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then return end

    local playerFunds = module._getPlayerFunds(player, playerState, currencyType)
    if not playerFunds then return end

    if not module._doesPlayerHasFunds(player, currencyType, playerFunds, totalPrice) then
        local action = {
            name="request",
            signal=("No%s"):format(currencyType),
        }
        playerState:set("Session", "Gui", action)
        return
    end
    return true
end

return module