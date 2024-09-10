local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local RejoinTestRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "RejoinTest"})

local localPlayer = Players.LocalPlayer

local PlayerRejoinTestC = {}
PlayerRejoinTestC.__index = PlayerRejoinTestC
PlayerRejoinTestC.className = "PlayerRejoinTest"
PlayerRejoinTestC.TAG_NAME = PlayerRejoinTestC.className

function PlayerRejoinTestC.new(player)
    if player ~= localPlayer then return end
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerRejoinTestC)

    print("Start RJ")

    local delay_
    if RunService:IsStudio() then
        delay_ = 5
    else
        delay_ = 30
    end
    task.wait(delay_)
    if self.player.Parent then
        RejoinTestRE.OnClientEvent:Connect(function(message)
            print(message)
        end)
    end

    return self
end

function PlayerRejoinTestC:Destroy()
    self._maid:Destroy()
end

return PlayerRejoinTestC