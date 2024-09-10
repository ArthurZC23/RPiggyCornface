local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local RootF = script:FindFirstAncestor("PlayerHadesC")
local DeathHooks = require(RootF.DeathHooks.DeathHooks)

local localPlayer = Players.LocalPlayer

local PlayerHadesC = {}
PlayerHadesC.__index = PlayerHadesC
PlayerHadesC.className = "PlayerHades"
PlayerHadesC.TAG_NAME = PlayerHadesC.className

function PlayerHadesC.new(player)
    if player ~= localPlayer then return end
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerHadesC)

    if not self:getFields(player) then return end
    self:handleDeathHooks()

    return self
end

function PlayerHadesC:handleDeathHooks()
    self.DeathHookRE.OnClientEvent:Connect(function(deathCause, kwargs)
        kwargs = kwargs or {}
        DeathHooks[deathCause](self, kwargs)
    end)
end

function PlayerHadesC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local remotes = {
                "DeathHook",
            }
            local root = self.player
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerHadesC:Destroy()
    self._maid:Destroy()
end

return PlayerHadesC