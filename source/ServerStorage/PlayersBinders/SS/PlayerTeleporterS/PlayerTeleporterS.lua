local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local Debounce = Mod:find({"Debounce", "Debounce"})
local GameData = Data.Game.Game
local OtherGamesData = GameData.otherGames

local ServerTypesData = Data.Game.ServerTypes

local PlayerTeleporterS = {}
PlayerTeleporterS.__index = PlayerTeleporterS
PlayerTeleporterS.className = "PlayerTeleporter"
PlayerTeleporterS.TAG_NAME = PlayerTeleporterS.className

function PlayerTeleporterS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerTeleporterS)

    self:createRemotes()
    self:handleTeleportRequest()

    return self
end

function PlayerTeleporterS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"TeleportToOtherGame",},
        functions = {},
    }))
end

function PlayerTeleporterS:handleTeleportRequest()
    local function teleport(plr, otherGameData)
        if plr ~= self.player then return end
        local ok, err = pcall(function()
            local teleportOptions = Instance.new("TeleportOptions")
            -- print("D", ServerTypesData.ServerType)
            local teleportData = {
                placeId = game.PlaceId,
            }
            teleportOptions:SetTeleportData(teleportData)
            if
                ServerTypesData.ServerType == ServerTypesData.sTypes.LivePrivate
                or ServerTypesData.ServerType == ServerTypesData.sTypes.LiveTest
            then
                -- print("Teleport to test")
                TeleportService:TeleportAsync(otherGameData.TEST.placeId, {self.player}, teleportOptions)
                -- TeleportService:TeleportAsync(otherGameData.PRODUCTION.placeId, {self.player}, teleportOptions)
            elseif ServerTypesData.ServerType == ServerTypesData.sTypes.LiveProduction then
                -- print("Teleport to production")
                TeleportService:TeleportAsync(otherGameData.PRODUCTION.placeId, {self.player}, teleportOptions)
            end
        end)
        if not ok then
            warn(tostring(err))
        end
    end
    self.TeleportToOtherGameRE.OnServerEvent:Connect(Debounce.remotesCooldownPerPlayer(
        function(plr, gameName)
            local gameData = OtherGamesData[gameName]
            teleport(plr, gameData)
        end,
        2
    ))
end


function PlayerTeleporterS:Destroy()
    self._maid:Destroy()
end

return PlayerTeleporterS