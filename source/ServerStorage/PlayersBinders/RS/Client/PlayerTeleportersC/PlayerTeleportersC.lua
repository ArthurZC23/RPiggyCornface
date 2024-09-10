local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local PlayerTeleportersC = {}
PlayerTeleportersC.__index = PlayerTeleportersC
PlayerTeleportersC.className = "PlayerTeleporters"
PlayerTeleportersC.TAG_NAME = PlayerTeleportersC.className

function PlayerTeleportersC.new(player)
    if localPlayer ~= player then return end

    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerTeleportersC)

    if not self:getFields() then return end

    self:setupTeleporters()

    return self
end

function PlayerTeleportersC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerTeleportersC:setupTeleporters()

end

function PlayerTeleportersC:Destroy()
    self._maid:Destroy()
end

return PlayerTeleportersC