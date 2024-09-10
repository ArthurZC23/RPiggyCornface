local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local RootF = script:FindFirstAncestor("CharHadesC")
local DeathHooks = require(RootF.DeathHooks.DeathHooks)

local CharHadesC = {}
CharHadesC.__index = CharHadesC
CharHadesC.className = "CharHades"
CharHadesC.TAG_NAME = CharHadesC.className

function CharHadesC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharHadesC)

    if not self:getFields(char) then return end
    self:handleDeathHooks()

    return self
end

function CharHadesC:handleDeathHooks()
    self.DeathHookRE.OnClientEvent:Connect(function(deathCause, kwargs)
        kwargs = kwargs or {}
        DeathHooks[deathCause](self, kwargs)
    end)
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharHadesC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                "DeathHook",
            }
            local root = self.char
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharHadesC:Destroy()
    self._maid:Destroy()
end

return CharHadesC