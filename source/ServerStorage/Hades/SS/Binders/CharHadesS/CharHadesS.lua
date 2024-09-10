-- CharHades is destroyed before Player Hades when player leaves the game
-- Handle char death (kill effects, scary jumps)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local RootF = script:FindFirstAncestor("CharHadesS")
local DeathHooks = require(RootF.DeathHooks.DeathHooks)

local CharHadesS = {}
CharHadesS.__index = CharHadesS
CharHadesS.className = "CharHades"
CharHadesS.TAG_NAME = CharHadesS.className

function CharHadesS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharHadesS)

    if not self:getFields(char) then return end
    if self.player then
        self:createRemotes()
    end
    self:createSignals()

    self._kill = Debounce.oneExecution(self._kill)

    -- Necessary for when fallen of the map with no neck rig
    -- Cannot remove char from workspace
    self._maid:Add2(self.charParts.hrp.AncestryChanged:Connect(function(_, parent)
        if not parent then self:_kill() end
    end), "RemoveHrp")

    self:handleKillSignal()
    self:handleWithDeathByHealth()

    return self
end

function CharHadesS:handleKillSignal()
    self._maid:Add2(self.KillSignalSE:Connect(function(deathCause, kwargs)
        self:_kill(deathCause, kwargs)
    end))
end

function CharHadesS:handleWithDeathByHealth()
    self._maid:Add2(self.charParts.humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        local health = self.charParts.humanoid.Health
        if health <= 0 then
            self.KillSignalSE:Fire()
        end
    end))

    -- self._maid:Add(self.charParts.humanoid.Died:Connect(function ()
    --     self:_kill()
    -- end))
end

function CharHadesS:_kill(deathCause, kwargs)
    -- print("[CharHadesS:_kill]  1 Death cause:", deathCause)
    -- print(debug.traceback(nil, 2))
    kwargs = kwargs or {}
    deathCause = deathCause or "Default"
    local hook = DeathHooks[deathCause]
    kwargs.deathCause = deathCause
    self.char:SetAttribute("Dead", true)
    local timeout = 30
    if RunService:IsStudio() then
        -- timeout = 1e3
    end
    Promise.try(function()
        -- print("[CharHadesS:_kill]  2 Death cause:", deathCause)
        self.BeforeDeathSE:Fire()
        return hook(self, kwargs)
    end)
        :timeout(timeout)
        :catchAndPrint()
        :andThen(function()
            -- https://devforum.roblox.com/t/playermove-called-but-player-currently-has-no-humanoid/206853/7
            -- print("[CharHadesS:_kill]  3 Death cause:", deathCause)
            if not kwargs.handlerDestroysChar then
                -- print("[CharHadesS:_kill]  3.1. Destroy char")
                self.char.Parent = nil
                self.char:Destroy()
            end

            if self.player then
                -- requires mandatory wait to allow to playerHades to destroy in case player is leaving
                -- else playerHades is called twice. Once here and once again when it gets destroyed.
                task.wait(0.1)
                -- print("[CharHadesS:_kill]  4. player hades _kill")
                kwargs.char = self.char
                local PlayerKillSE = SharedSherlock:find({"Bindable", "sync"}, {root = self.player, signal = "PlayerKill"})
                if not PlayerKillSE then return end
                if PlayerKillSE then
                    PlayerKillSE:Fire(kwargs)
                end
            end
        end)
        :catchAndPrint()

end

function CharHadesS:getKillSignalE()
    return self.KillSignalSE
end

function CharHadesS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"DeathHook"},
        functions = {},
    }))
end

function CharHadesS:createSignals()
    self._maid:Add(GaiaShared.createBinderSignals(self, self.char, {
        events = {"KillSignal", "BeforeDeath"},
    }))
end

function CharHadesS:getFields(char)
    local charType = CharUtils.getCharType(char)
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            do
                local bindersData = {
                    {"CharState", self.char},
                    {"CharParts", self.char},
                    {"CharProps", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            if charType == "PCharacter" then
                self.player = PlayerUtils:GetPlayerFromCharacter(char)
                if not self.player then return end

                local bindersData = {
                    {"PlayerHades", self.player},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharHadesS:Destroy()
    self._maid:Remove("RemoveHrp")
    self:_kill()
    self._maid:Destroy()
end

return CharHadesS