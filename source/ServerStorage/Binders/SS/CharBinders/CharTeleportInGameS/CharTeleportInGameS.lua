local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local CharTeleportInGameS = {}
CharTeleportInGameS.__index = CharTeleportInGameS
CharTeleportInGameS.className = "CharTeleportInGame"
CharTeleportInGameS.TAG_NAME = CharTeleportInGameS.className

local Sampler = Mod:find({"Math", "Sampler"})
CharTeleportInGameS.spawnSampler = Sampler.new()

function CharTeleportInGameS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharTeleportInGameS)
    if not self:getFields() then return end
    self:createSignals()
    self:handleTeleport()

    return self
end

local CFrameUtils = Mod:find({"Mosby", "CFrameUtils"})
function CharTeleportInGameS:sampleCfFromTargets(kwargs)
    local Target = CharTeleportInGameS.spawnSampler:sampleArray(kwargs.Targets)
    return CFrameUtils.pivotOnWorldTop(self.char, Target)
end

function CharTeleportInGameS:handleTeleport()
    self._maid:Add2(self.CharTeleportSE:Connect(function(kwargs)
        if kwargs.Targets then
            kwargs.cf = self:sampleCfFromTargets(kwargs)
        end
        assert(kwargs.cf)
        local action = {
            name="teleport",
            kwargs=kwargs
        }
        self.playerState:set("Session", "Teleport", action)
    end))
    self._maid:Add2(self.CharTeleportServerSE:Connect(function(kwargs)
        if kwargs.Targets then
            kwargs.cf = self:sampleCfFromTargets(kwargs)
        end
        self.char:PivotTo(kwargs.cf)
    end))
end

function CharTeleportInGameS:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.char, {
        events = {"CharTeleport", "CharTeleportServer"},
    }))
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Players = game:GetService("Players")
function CharTeleportInGameS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player =  Players:GetPlayerFromCharacter(self.char)
            if not self.player then return end
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharTeleportInGameS:Destroy()
    self._maid:Destroy()
end

return CharTeleportInGameS