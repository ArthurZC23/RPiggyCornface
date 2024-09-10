local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = script:FindFirstAncestor("Data")
local GameData = require(Data.Game.Game)
local Mts = Mod:find({"Table", "Mts"})

local module = {}

module.sTypes = {
    ["StudioNotPublished"] = "StudioNotPublished",
    ["StudioPublishedPrivate"] = "StudioPublishedPrivate",
    ["StudioPublishedTest"] = "StudioPublishedTest",
    ["StudioPublishedProduction"] = "StudioPublishedProduction",
    ["LivePrivate"] = "LivePrivate",
    ["LiveTest"] = "LiveTest",
    ["LiveProduction"] = "LiveProduction",
}
module.sTypes = Mts.makeEnum("ServerTypes", module.sTypes)

module.sAccessTypes = {
    ["Standard"] = "Standard",
    ["Reserved"] = "Reserved",
    ["Vip"] = "Vip",
}
module.sAccessTypes = Mts.makeEnum("ServerAccessTypes", module.sAccessTypes)

if RunService:IsStudio() then
    if game.PlaceId == 0 then
        module.ServerType = module.sTypes.StudioNotPublished
    elseif GameData.placeIds[game.PlaceId] == "PRIVATE" then
        module.ServerType = module.sTypes.StudioPublishedPrivate
    elseif GameData.placeIds[game.PlaceId] == "TEST" then
        module.ServerType = module.sTypes.StudioPublishedTest
    elseif GameData.placeIds[game.PlaceId] == "PRODUCTION" then
        module.ServerType = module.sTypes.StudioPublishedProduction
    else
        error(("Server with game id %s is not a valid server."):format(game.PlaceId))
    end
else
    if GameData.placeIds[game.PlaceId] == "TEST" then
        module.ServerType = module.sTypes.LiveTest
    elseif GameData.placeIds[game.PlaceId] == "PRIVATE" then
        module.ServerType = module.sTypes.LivePrivate
    elseif GameData.placeIds[game.PlaceId] == "PRODUCTION" then
        module.ServerType = module.sTypes.LiveProduction
    else
        error(("Server with game id %s is not a valid server."):format(game.PlaceId))
    end
end

if game.PrivateServerId ~= "" then
    if game.PrivateServerOwnerId ~= 0 then
        module.ServerAccessType = module.sAccessTypes.Vip
        module.serverOwnerId = game.PrivateServerOwnerId
    else
        module.ServerAccessType = module.sAccessTypes.Reserved
    end
else
    module.ServerAccessType = module.sAccessTypes.Standard
end

return module