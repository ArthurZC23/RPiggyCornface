local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local GpData = Data.GamePasses.GamePasses
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local RootF = script.Parent
local GamePassesHandlers = require(RootF.GamePassesHandlers)

local localPlayer = Players.LocalPlayer

local PlayerGamePassesC = {}
PlayerGamePassesC.__index = PlayerGamePassesC
PlayerGamePassesC.className = "PlayerGamePasses"
PlayerGamePassesC.TAG_NAME = PlayerGamePassesC.className

function PlayerGamePassesC.new(player)
    if player ~= localPlayer then return end
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerGamePassesC)
    if not self:getFields() then return end

    self:applyGamePasses()
    return self
end

function PlayerGamePassesC:applyGamePasses()
    local function update(gpId)
        local gpData = Data.GamePasses.GamePasses.idToData[gpId]
        if not gpData then return end
        local gpName = gpData["name"]
        if GamePassesHandlers[gpName] then
            GamePassesHandlers[gpName](self.playerState)
        end
    end

    self.playerState:getEvent("Stores", "GamePasses", "addGamePass"):Connect(function(_, action)
        update(action.id)
    end)
    for gpId in pairs(self.playerState:get("Stores", "GamePasses").st) do
        update(gpId)
    end
end

function PlayerGamePassesC:getFields()
    return WaitFor.GetAsync({
        getter=function()

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
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerGamePassesC:Destroy()
    self._maid:Destroy()
end

return PlayerGamePassesC