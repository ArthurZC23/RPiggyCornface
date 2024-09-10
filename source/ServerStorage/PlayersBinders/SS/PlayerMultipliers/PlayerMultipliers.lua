local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local FastSpawn = Mod:find({"FastSpawn"})

local RootF = script:FindFirstAncestor("PlayerMultipliers")
local UpdatesF = RootF.Updates

local UpdateModules = {}
for _, child in ipairs(UpdatesF:GetChildren()) do
    UpdateModules[child.Name] = require(child)
end

local PlayerMultipliers = {}
PlayerMultipliers.__index = PlayerMultipliers
PlayerMultipliers.className = "PlayerMultipliers"
PlayerMultipliers.TAG_NAME = PlayerMultipliers.className

function PlayerMultipliers.new(player)
    local self = {
        _maid = Maid.new(),
        player = player
    }
    setmetatable(self, PlayerMultipliers)
    if not self:getFields() then return end
    self:handleMultipliersUpdates()

    return self
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

function PlayerMultipliers:handleMultipliersUpdates()
    for _, child in ipairs(UpdatesF:GetChildren()) do
        FastSpawn(UpdateModules[child.name].update, self.playerState)
    end
end

function PlayerMultipliers:getFields()
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

function PlayerMultipliers:Destroy()
    self._maid:Destroy()
end

return PlayerMultipliers