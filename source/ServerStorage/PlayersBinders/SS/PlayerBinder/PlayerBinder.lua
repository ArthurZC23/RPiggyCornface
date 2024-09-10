local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local SignalE = Mod:find({"Signal", "Event"})

local PlayerBinder = {}
PlayerBinder.__index = PlayerBinder
PlayerBinder.className = "PlayerBinder"
PlayerBinder.TAG_NAME = PlayerBinder.className

function PlayerBinder.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerBinder)
    self.TheCharacterReadySE = SignalE.new()
    self.TheCharacterRemovingSE = SignalE.new()

    self:createRemotes()
    self:createSignals()
    self:handleCharacterLifecycle()

    return self
end

function PlayerBinder:createRemotes()
    local eventsNames = {}
    local functionsNames = {}
    GaiaServer.createRemotes(self.player, {
        events = eventsNames,
        functions = functionsNames,
    })
    for _, eventName in ipairs(eventsNames) do
        self[("%sRE"):format(eventName)] = self.player.Remotes.Events[eventName]
    end
    for _, funcName in ipairs(functionsNames) do
        self[("%sRF"):format(funcName)] = self.player.Remotes.Functions[funcName]
    end
end

function PlayerBinder:createSignals()
    local eventsNames = {}
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.player, {
        events = eventsNames,
    }))
end

function PlayerBinder:handleCharacterLifecycle()
    self.player.CharacterAdded:Connect(function(char)
        CollectionService:AddTag(char, "PlayerCharacter")
    end)

    local char = self.player.Character
    if char then
        CollectionService:AddTag(char, "PlayerCharacter")
    end
end

function PlayerBinder:Destroy()
    self._maid:Destroy()
end

return PlayerBinder