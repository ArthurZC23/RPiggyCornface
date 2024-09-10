local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharSpeedHumanC = {}
CharSpeedHumanC.__index = CharSpeedHumanC
CharSpeedHumanC.className = "CharSpeedHuman"
CharSpeedHumanC.TAG_NAME = CharSpeedHumanC.className

local function setAttributes()

end
setAttributes()

function CharSpeedHumanC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharSpeedHumanC)

    -- if not self:getFields() then return end
    -- self:handleSpeed()
    -- self:handleJump()
    -- self:handleTransparency()

    return self
end

local BoostsData = Data.Boosts.Boosts
function CharSpeedHumanC:handleSpeed()
    local function update(state)
        local boostId = BoostsData.nameData[S.SpeedBoost].id
        local prop = self.charProps.props[self.charParts.humanoid]
        local property = "WalkSpeed"
        local cause = "Boost"
        if state.st[boostId] then
            prop:set(property, cause, 22)
        else
            prop:removeCause(property, cause)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "removeBoost"):Connect(update))
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "addBoost"):Connect(update))
    local state = self.playerState:get(S.Stores, "Boosts")
    update(state)
end

function CharSpeedHumanC:handleJump()
    local function update(state)
        local boostId = BoostsData.nameData[S.JumpBoost].id
        local prop = self.charProps.props[self.charParts.humanoid]
        local property = "JumpPower"
        local cause = "Boost"
        if state.st[boostId] then
            prop:set(property, cause, 80)
        else
            prop:removeCause(property, cause)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "removeBoost"):Connect(update))
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "addBoost"):Connect(update))
    local state = self.playerState:get(S.Stores, "Boosts")
    update(state)
end

local Players = game:GetService("Players")
function CharSpeedHumanC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            if not self.player then return nil, "Player" end

            local BinderUtils = Mod:find({"Binder", "Utils"})
            do
                local bindersData = {
                    {"CharParts", self.char},
                    {"CharProps", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end
            do
                local bindersData = {
                    {"PlayerState", self.player},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=1
    })
    return ok
end

function CharSpeedHumanC:Destroy()
    self._maid:Destroy()
end

return CharSpeedHumanC