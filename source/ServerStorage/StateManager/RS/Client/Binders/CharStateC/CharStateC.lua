local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local RootFolder = script.Parent
local StateTypeComponents = {
    [S.LocalSession] = require(ComposedKey.getAsync(RootFolder, {"CharLocalSession", "CharLocalSessionC"})),
    [S.Session] = require(ComposedKey.getAsync(RootFolder, {"CharSession", "CharSessionC"})),
}

local CharStateC = {}
CharStateC.__index = CharStateC
CharStateC.className = "CharState"
CharStateC.TAG_NAME = CharStateC.className

function CharStateC.new(char)
    -- print("[CharStateC] 1")
    if not CharUtils.isLocalChar(char) then return end

    -- print("[CharStateC] 2")

    local self = {
        _maid = Maid.new(),
        char = char,
        _stateTypes = {},

    }
    setmetatable(self, CharStateC)
    if not self:getFields() then return end
    if not BinderUtils.initComponents(self, StateTypeComponents , {accessTable=self._stateTypes}) then return end

    -- print("[CharStateC] 3")

    return self
end

function CharStateC:get(stateType, scope)
    return self._stateTypes[stateType]:get(scope)
end

function CharStateC:set(stateType, scope, action)
    local kwargs = self._stateTypes[stateType]:set(scope, action)
    return kwargs
end

function CharStateC:sync(stateType, scope, action)
    self._stateTypes[stateType].Replicator:sync(scope, action)
end

function CharStateC:getEvent(stateType, scope, eventName)
    return self._stateTypes[stateType]:getEvent(scope, eventName)
end

function CharStateC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            if CharUtils.isPChar(self.char) then
                self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
                if not self.player then return end
            end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharStateC:Destroy()
    self._maid:Destroy()
end

return CharStateC