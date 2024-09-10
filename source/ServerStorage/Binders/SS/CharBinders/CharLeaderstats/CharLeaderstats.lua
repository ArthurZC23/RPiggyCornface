local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local UpdateLeaderstats = Data.Scores.UpdateLeaderstats
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local CharLeaderstats = {}
CharLeaderstats.__index = CharLeaderstats
CharLeaderstats.className = "CharLeaderstats"
CharLeaderstats.TAG_NAME = CharLeaderstats.className

function CharLeaderstats.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharLeaderstats)
    if not self:getFields() then return end
    self:initializeLeaderstats()

    return self
end

function CharLeaderstats:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            self.leaderstats = self.player:FindFirstChild("leaderstats")
            if not self.leaderstats then return end

            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharState", self.char},
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
        cooldown=1
    })
end

function CharLeaderstats:initializeLeaderstats()
    for _, stat in ipairs(UpdateLeaderstats) do
        if stat.stateManager ~= "charState" then continue end
        local statV = self._maid:Add(GaiaShared.create(stat.type_, {
            Name = stat.prettyName,
            Parent = self.leaderstats,
        }))
        self._maid:Add(self.charState:getEvent(stat.stateType, stat.scope, stat.eventName):Connect(function(state, action)
            if self.charState.isDestroyed then return end
            stat.update(statV, state, action, self.charState)
        end))
        stat.update(statV, self.charState:get(stat.stateType, stat.scope), self.charState)
    end
end

function CharLeaderstats:Destroy()
    self._maid:Destroy()
end

return CharLeaderstats