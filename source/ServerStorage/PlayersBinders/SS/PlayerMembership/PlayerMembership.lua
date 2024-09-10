local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerMembership = {}
PlayerMembership.__index = PlayerMembership
PlayerMembership.className = "PlayerMembership"
PlayerMembership.TAG_NAME = PlayerMembership.className

function PlayerMembership.update(player)
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then return end
    do
        local action = {
           name="update",
           value = player.MembershipType,
        }
        playerState:set(S.Session, "Membership", action)
    end
end
Players.PlayerMembershipChanged:Connect(PlayerMembership.update)

function PlayerMembership.new(player)
    local self = {}
    setmetatable(self, PlayerMembership)
    self.player = player
    self._maid = Maid.new()

    FastSpawn(PlayerMembership.update, player)

    return self
end

function PlayerMembership:Destroy()
    self._maid:Destroy()
end

return PlayerMembership