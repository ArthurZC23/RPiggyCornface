local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Data = Mod:find({"Data", "Data"})
local AutoSaveData = Data.DataStore.AutoSave

local PlayerAutoSave = {}
PlayerAutoSave.__index = PlayerAutoSave
PlayerAutoSave.className = "PlayerAutoSave"
PlayerAutoSave.TAG_NAME = PlayerAutoSave.className

function PlayerAutoSave.new(player)
    local self = {}
    setmetatable(self, PlayerAutoSave)
    self._maid = Maid.new()

    FastSpawn(function()
        self:autoSave(player)
    end)

    return self
end

function PlayerAutoSave:autoSave(player)
    local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
    if not playerState then return end

    -- Save as soon as game starts, in order to win data validation badge
    Cronos.wait(10)
    while player.Parent do
        playerState:pushToSaveScheduler(playerState)
        wait(AutoSaveData.interval)
    end
end

function PlayerAutoSave:Destroy()
    self._maid:Destroy()

end

return PlayerAutoSave