local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local placeIds = Data.Game.Game.placeIds

local RFunctions = ReplicatedStorage.Remotes.Functions
local GetServerTypeRF = RFunctions:WaitForChild("GetServerType")

local isStudio = RunService:IsStudio()
local PLACE_ID = game.PlaceId

local module = {}

module.STUDIO = 1
module.TEST = 2
module.PRODUCTION = 3
module.VipServer = 4
module.ReservedServer = 5
module.StandardServer = 6

function module.getServerType()
    if isStudio then
        return module.STUDIO
    elseif placeIds[PLACE_ID] == "PRODUCTION" then
        return module.PRODUCTION
    elseif placeIds[PLACE_ID] == "TEST" then
        return module.TEST
    end
    error(("Server type not defined for place %s"):format(PLACE_ID))
end

function module.getServerAccessType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return module.VipServer
		else
			return module.ReservedServer
		end
	else
		return module.StandardServer
	end
end
module.serverAccessType = module.getServerAccessType()
module.isReservedServer = module.serverAccessType == module.ReservedServer
module.isVipServer = module.serverAccessType == module.VipServer
module.isPrivateServer = (module.serverAccessType == module.VipServer) or ( module.serverAccessType == module.ReservedServer)

function module.getServerOwner()
    return game.PrivateServerOwnerId
end

GetServerTypeRF.OnServerInvoke = function(_)
    return module.getServerType()
end

return module