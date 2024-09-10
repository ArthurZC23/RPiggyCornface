-- Handle player death notification and respawn

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local RootF = script:FindFirstAncestor("PlayerHadesS")
local DeathHooks = require(RootF.DeathHooks.DeathHooks)

local PlayerHadesS = {}
PlayerHadesS.__index = PlayerHadesS
PlayerHadesS.className = "PlayerHades"
PlayerHadesS.TAG_NAME = PlayerHadesS.className

function PlayerHadesS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerHadesS)

    if not self:getFields(player) then return end

    if self.player then
        self:createRemotes()
    end
    self:createSignals()

    self._maid:Add2(self.PlayerKillSE:Connect(function(kwargs)
        self:_kill(kwargs)
    end))

    return self
end

function PlayerHadesS:_kill(kwargs)
    -- print("[PlayerHadesS:_kill]  1 Death cause:", kwargs.deathCause)
    local hook = DeathHooks[kwargs.deathCause]
    local timeout = 30
    if RunService:IsStudio() then
        -- timeout = 1e3
    end

    -- These signals bug when the player leaves, because they're destroyed before they're called.
    self.CharDeathSE:Fire(self.player, kwargs)
    self.CharDeathRE:FireClient(self.player)

    -- print(self._maid.isDestroyed)
    self._maid:Add2(Promise.try(function()
        -- print("[PlayerHadesS:_kill]  2 Death cause:", kwargs.deathCause)
        return hook(self, kwargs)
    end)
    :timeout(timeout)
    :catchAndPrint()
    :andThen(function()
        -- print("[PlayerHadesS:_kill]  3 Death cause:", kwargs.deathCause)
        self.CharRespawnSE:Fire()
    end)
    :catchAndPrint(),
    "KillPromise")
end

function PlayerHadesS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"DeathHook", "CharDeath"},
        functions = {},
    }))
end

function PlayerHadesS:createSignals()
    self._maid:Add(GaiaShared.createBinderSignals(self, self.player, {
        events = {"CharDeath", "CharRespawn", "PlayerKill"},
    }))
end

function PlayerHadesS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerHadesS:Destroy()
    self:_kill({deathCause="PlayerLeft"})
    self._maid:Destroy()
end

return PlayerHadesS