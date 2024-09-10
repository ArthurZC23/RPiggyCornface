local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local GaiaServer = Mod:find({"Gaia", "Server"})

local CharTitleS = {}
CharTitleS.__index = CharTitleS
CharTitleS.className = "CharTitle"
CharTitleS.TAG_NAME = CharTitleS.className

function CharTitleS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharTitleS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()

    self:handleTitles()

    return self
end

function CharTitleS:handleTitles()
    if RunService:IsStudio() then
        self.charParts.humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    else
        self.charParts.humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
    end
end

function CharTitleS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function CharTitleS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.charEvents, {
        events = {},
        functions = {},
    }))
end

function CharTitleS:getFields()
    return WaitFor.GetAsync({
        getter=function()

            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            local bindersData = {
                {"PlayerState", self.player},
                {"CharState", self.char},
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function CharTitleS:Destroy()
    self._maid:Destroy()
end

return CharTitleS