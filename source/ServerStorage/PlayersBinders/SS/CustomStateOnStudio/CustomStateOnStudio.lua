local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local ServerType = Mod:find({"ServerType"})
local GameData = Data.Game.Game
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local S = Data.Strings.Strings

local CustomStateOnStudio = {}
CustomStateOnStudio.__index = CustomStateOnStudio
CustomStateOnStudio.className = "CustomStateOnStudio"
CustomStateOnStudio.TAG_NAME = CustomStateOnStudio.className

function CustomStateOnStudio.new(player)
    -- ONE OF THOSE NEED TO BE ACTIVE
    -------------------------
    if not RunService:IsStudio() then return end
    if game.PlaceId ~= 0 then return end
    ---------------------

    --if not RunService:IsStudio() then return end

    -- if not (
    --     RunService:IsStudio()
    --     or (ServerType.getServerType() == ServerType.TEST))
    -- then return end
    ------------------
    if not (player.UserId == 925418276  or player.UserId < 0)  then return end

    -- DON'T CHANGE THIS
    if  GameData.placeIds[game.PlaceId] == "PRODUCTION" then return end

    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, CustomStateOnStudio)

    self:setStores(player)
    self:setSession(player)

    return self
end

function CustomStateOnStudio:setStores(player)
    self._maid:Add(WaitFor.BObj(player, "PlayerState")
    :andThen(function(playerState)

    end))
end

function CustomStateOnStudio:setSession(player)
    self._maid:Add(WaitFor.BObj(player, "PlayerState")
    :andThen(function(playerState)

    end))
end

function CustomStateOnStudio:Destroy()
    self._maid:Destroy()
end

return CustomStateOnStudio