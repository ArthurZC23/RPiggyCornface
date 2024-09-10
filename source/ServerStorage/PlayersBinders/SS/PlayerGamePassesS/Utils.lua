local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.doesPlayerHasGamePass(playerState, gpId)
    local player = playerState.player
    local gpState = playerState:get(S.Stores, "GamePasses")
    if RunService:IsStudio() and Data.Studio.Studio.gps.hasGps then
        warn("Studio hasGps is on")

        local studioGpData = Data.Studio.Studio.gps.hasGps[gpId]
        return Promise.resolve(studioGpData and studioGpData._d == nil)
    end
    if gpState.st[gpId] then
        return Promise.resolve(gpState.st[gpId]._d == nil)
    end

    local MAX_TRIES = 3
    return Promise.retry(
        function()
            return Promise.try(function ()
                return MarketplaceService:UserOwnsGamePassAsync(player.UserId, tonumber(gpId))
            end)
        end,
        MAX_TRIES
    )
        :timeout(15)
        :catch(function(err)
            warn(tostring(err))
        end)
end

return module