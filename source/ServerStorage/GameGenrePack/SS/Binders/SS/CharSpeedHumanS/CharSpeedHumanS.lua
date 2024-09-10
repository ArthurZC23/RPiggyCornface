local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local BoostsData = Data.Boosts.Boosts
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharSpeedHumanS = {}
CharSpeedHumanS.__index = CharSpeedHumanS
CharSpeedHumanS.className = "CharSpeedHuman"
CharSpeedHumanS.TAG_NAME = CharSpeedHumanS.className

local function setAttributes()

end
setAttributes()

function CharSpeedHumanS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharSpeedHumanS)

    if not self:getFields() then return end
    self:handleSpeed()
    self:handleJump()
    self:handleTransparency()

    return self
end

function CharSpeedHumanS:handleSpeed()
    local function update(state)
        local boostId = BoostsData.nameData[S.SpeedBoost].id
        local prop = self.charProps.props[self.charParts.humanoid]
        local property = "WalkSpeed"
        local cause = "Boost"
        if state.st[boostId] then
            prop:set(property, cause, 26)
        else
            prop:removeCause(property, cause)
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "removeBoost"):Connect(update))
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "addBoost"):Connect(update))
    local state = self.playerState:get(S.Stores, "Boosts")
    update(state)
end

function CharSpeedHumanS:handleJump()
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

function CharSpeedHumanS:handleTransparency()
    local function update(state)
        local boostId = BoostsData.nameData[S.GhostBoost].id
        if state.st[boostId] then
            local maid = self._maid:Add2(Maid.new(), "SetGhostTransparency")
            local property = "Transparency"
            local cause = "Boost"

            maid:Add2(function()
                for _, desc in ipairs(self.char:GetDescendants()) do
                    if desc:GetAttribute("transpDefault") == nil then continue end
                    local prop = self.charProps.props[desc]
                    if not prop then continue end
                    prop:removeCause(property, cause)
                end
            end)

            local function setTransp(inst)
                if inst:GetAttribute("transpDefault") == nil then return end
                local prop = self.charProps.props[inst]
                if not prop then return end
                prop:set(property, cause, 0.5)
            end
            for _, desc in ipairs(self.char:GetDescendants()) do
                setTransp(desc)
            end

        else
            self._maid:Remove("SetGhostTransparency")
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "removeBoost"):Connect(update))
    self._maid:Add(self.playerState:getEvent(S.Stores, "Boosts", "addBoost"):Connect(update))
    local state = self.playerState:get(S.Stores, "Boosts")
    update(state)
end

function CharSpeedHumanS:getFields()
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

function CharSpeedHumanS:Destroy()
    self._maid:Destroy()
end

return CharSpeedHumanS