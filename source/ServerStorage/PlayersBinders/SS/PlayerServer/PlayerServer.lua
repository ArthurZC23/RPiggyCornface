local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerServer = {}
PlayerServer.__index = PlayerServer
PlayerServer.className = "PlayerServer"
PlayerServer.TAG_NAME = PlayerServer.className

function PlayerServer.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerServer)

    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end
    self:updatePlaceVersion(playerState)

    return self
end

function PlayerServer:updatePlaceVersion(playerState)
    local action = {
        name="UpdatePlaceVersion",
    }
    playerState:set(S.Stores, "Server", action)
end

function PlayerServer:Destroy()
    self._maid:Destroy()
end

return PlayerServer