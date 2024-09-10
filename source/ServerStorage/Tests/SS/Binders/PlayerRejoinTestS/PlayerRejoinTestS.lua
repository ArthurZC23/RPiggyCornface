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
local GaiaServer = Mod:find({"Gaia", "Server"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

GaiaServer.createRemotes(ReplicatedStorage, {
    events = {
        "RejoinTest",
    },
})

local RejoinTestRE = ReplicatedStorage.Remotes.Events.RejoinTest

local PlayerRejoinTest = {}
PlayerRejoinTest.__index = PlayerRejoinTest
PlayerRejoinTest.className = "PlayerRejoinTest"
PlayerRejoinTest.TAG_NAME = PlayerRejoinTest.className

function PlayerRejoinTest.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerRejoinTest)

    RejoinTestRE:FireClient(self.player, "Rejoin test")

    return self
end

function PlayerRejoinTest:Destroy()
    self._maid:Destroy()
end

return PlayerRejoinTest