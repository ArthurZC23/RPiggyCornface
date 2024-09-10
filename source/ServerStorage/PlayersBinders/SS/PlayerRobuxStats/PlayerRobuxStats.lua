local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local S = Data.Strings.Strings
local Promise = Mod:find({"Promise", "Promise"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

local PlayerRobuxStats = {}
PlayerRobuxStats.__index = PlayerRobuxStats
PlayerRobuxStats.className = "PlayerRobuxStats"
PlayerRobuxStats.TAG_NAME = PlayerRobuxStats.className

function PlayerRobuxStats.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
        components = {},
    }
    setmetatable(self, PlayerRobuxStats)

    self:createBindables()
    self:handleRobuxStatsUpdate()

    return self
end

function PlayerRobuxStats:createBindables()
    GaiaShared.createBindables(self.player, {
        events = {"UpdateRobuxStats"},
    })
    self.UpdateRobuxStatsSE = SharedSherlock:find(
        {"Bindable", "async"}, {root=self.player,
        signal="UpdateRobuxStats"})
end

function PlayerRobuxStats:handleRobuxStatsUpdate()
    self.UpdateRobuxStatsSE:Connect(function(purchaseType, productId)
        productId = tostring(productId)
        self[("handle%sPurchase"):format(purchaseType)](self, productId)
    end)
end

function PlayerRobuxStats:handleDevProductPurchase(productId)
    local p1 = Promise.try(function()
        local DevProductsState = gameState:get("Session", "DevProducts")
        local productData = DevProductsState[productId]
        if productData then
            return DevProductsState
        else
            error(("Async developer product data was not available for %s"):format(productId))
        end
    end)
    local p2 = Promise.fromEvent(
        gameState:getEvent("Session", "DevProducts", "addDevProduct"),
        function(DevProductsState)
            local productData = DevProductsState[productId]
            return productData ~= nil
        end
    )
    local promise = Promise.any({p1, p2})
    promise
        :andThen(function(DevProductsState)
            local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=self.player})
            if not playerState then return end

            local productData = DevProductsState[productId]

            local action = {
                name = "addDevProduct",
                devProductPrice = productData.priceInRobux,
            }
            playerState:set("Stores", "RobuxStats", action)
        end)
        :catch(function (err)
            ErrorReport.report(self.player.UserId, tostring(err), "error")
        end)
end

function PlayerRobuxStats:handleGamePassPurchase(productId)
    local p1 = Promise.try(function()
        local GamePassesState = gameState:get("Session", "GamePasses")
        local productData = GamePassesState[productId]
        if productData then
            return GamePassesState
        else
            error(("Async gamepass data was not available for %s"):format(productId))
        end
    end)
    local p2 = Promise.fromEvent(
        gameState:getEvent("Session", "GamePasses", "addGamePass"),
        function(GamePassesState)
            local productData = GamePassesState[productId]
            return productData ~= nil
        end
    )
    local promise = Promise.any({p1, p2})
    promise
        :andThen(function(GamePassesState)
            local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=self.player})
            if not playerState then return end

            local productData = GamePassesState[productId]

            local action = {
                name = "addGp",
                gpPrice = productData.priceInRobux,
            }
            playerState:set("Stores", "RobuxStats", action)
        end)
        :catch(function (err)
            ErrorReport.report(self.player.UserId, tostring(err), "error")
        end)
end

function PlayerRobuxStats:Destroy()
    self._maid:Destroy()
end

return PlayerRobuxStats