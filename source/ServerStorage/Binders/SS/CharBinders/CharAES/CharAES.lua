local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SuperUsers = Data.Players.Roles.HiddenRoles.HiddenRoles.SuperUsers

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local Components = require(ServerStorage.Hooks.CharAES.Components.Components)

local CharAES = {}
CharAES.__index = CharAES
CharAES.className = "CharAE"
CharAES.TAG_NAME = CharAES.className

function CharAES.new(char)
    local player = Players:FindFirstChild(char.Name)
    if not player then return end

    if not RunService:IsStudio() then
        if SuperUsers[tostring(player.UserId)] then return end
    end

    local self = {
        player = player,
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharAES)

    if not self:initComponents() then
        self._maid:Destroy() -- This is not necessary
        return
    end

    return self
end

function CharAES:initComponents()
    for _, class in pairs(Components) do
        local obj = class.new(self.player, self.char)
        if obj then
            self._maid:Add(obj)
        else
            return false
        end
    end
    return true
end

function CharAES:Destroy()
    self._maid:Destroy()
end

return CharAES