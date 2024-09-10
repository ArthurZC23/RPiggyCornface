-- Use soft shutdown in library for teleport place

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local ServerTypesData = Data.Game.ServerTypes
local DsbStores = Data.DataStore.DsbStores
local GameData = Data.Game.Game
local updatePlaceId = GameData.updatePlaceIds[game.PlaceId]
local DataStoreB = require(ServerStorage.DataStoreB)

local BigNotificationGuiRE = ReplicatedStorage.Remotes.Events:WaitForChild("BigNotificationGui")

local PlayerBindToClose = {}
PlayerBindToClose.__index = PlayerBindToClose
PlayerBindToClose.className = "PlayerBindToClose"
PlayerBindToClose.TAG_NAME = PlayerBindToClose.className

function PlayerBindToClose.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerBindToClose)
    self:handleGameShutdown()

    -- do
    --     local envs = {
    --         [ServerTypesData.sTypes.LiveTest] = true,
    --     }
    --     if envs[ServerTypesData.ServerType] then
    --         task.delay(30, function()
    --             local teleportOptions = Instance.new("TeleportOptions")
    --             local teleportData = {
    --                 placeId = game.PlaceId,
    --             }
    --             teleportOptions:SetTeleportData(teleportData)
    --             -- teleportOptions.ShouldReserveServer = true
    --             local ok, err = pcall(function()
    --                 TeleportService:TeleportAsync(updatePlaceId, {self.player}, teleportOptions)
    --             end)
    --             if not ok then
    --                 self.player:Kick(err)
    --             end
    --         end)
    --     end
    -- end

    return self
end

function PlayerBindToClose:handleGameShutdown()
    self:handleWarning()
    -- self:handleTeleport()
end

function PlayerBindToClose:handleWarning()
    game:BindToClose(function()
        BigNotificationGuiRE:FireClient(
            self.player,
            "Game is about to update!",
            40
        )
    end)
end

function PlayerBindToClose:handleTeleport()

    if not RunService:IsStudio() then
        assert(updatePlaceId, "Production game requires update place for teleport.")
    end

    local store = DataStoreB(DsbStores.names.Datetime, self.player)

    local studioCallback = function()
        warn(("Teleport player %s to update place."):format(self.player.Name))
    end

    local callback = function()
        local teleportOptions = Instance.new("TeleportOptions")
        local teleportData = {
            placeId = game.PlaceId,
        }
        teleportOptions:SetTeleportData(teleportData)
        -- teleportOptions.ShouldReserveServer = true
        local ok = pcall(function()
            TeleportService:TeleportAsync(updatePlaceId, {self.player}, teleportOptions)
        end)
        if not ok then
            self.player:Kick("The game has just updated. Roblox couldn't teleport you to the latest version. Rejoin and have fun! :D")
        end
    end

    if RunService:IsStudio() then
        store:BindToClose(studioCallback)
    else
        store:BindToClose(callback)
    end
end

function PlayerBindToClose:Destroy()
    self._maid:Destroy()
end

return PlayerBindToClose