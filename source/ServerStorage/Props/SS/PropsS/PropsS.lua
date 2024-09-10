local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local Data = Mod:find({"Data", "Data"})
local Codec = Data.Props.PropsCodec

local PropsShared = ComposedKey.getAsync(ReplicatedStorage, {"Props", "Shared"})

local PropsS = {}
PropsS.__index = PropsS
PropsS.className = "Props"
PropsS.TAG_NAME = PropsS.className

function PropsS.new(inst)
    local self = {
        _maid = Maid.new(),
        inst = inst,
        properties = {},
        currentCause = {},
    }
    setmetatable(self, PropsS)
    return self
end

function PropsS:createSetter(prop, setter)
    local _setter
    if typeof(setter) ~= "function" then
        _setter = function()
            self.inst[prop] = setter
        end
    else
        _setter = setter
    end
    return _setter
end

function PropsS:getCurrentPriority(prop)
    local currentPriority
    if self.currentCause[prop] then
        currentPriority = tonumber(Codec.encoder[prop][self.currentCause[prop]])
    else
        currentPriority = Codec.NIL_CAUSE_PRIORITY
        self.currentCause[prop] = Codec.NIL_CAUSE
    end
    return currentPriority
end

function PropsS:addToPq(prop, cause, setter)
    self.properties[prop] = self.properties[prop] or {}
    local _setter = self:createSetter(prop, setter)
    self.properties[prop][cause] = {_setter}
    return _setter
end

function PropsS:set(prop, cause, setter)
    -- print("Set ", prop, cause, tostring(setter))
    local _setter = self:addToPq(prop, cause, setter)
    local priority = tonumber(Codec.encoder[prop][cause])
    local currentPriority = self:getCurrentPriority(prop)

    local hasNewCauseMaxPriority = (priority > currentPriority)
    if hasNewCauseMaxPriority then
        self:_set(prop, cause, _setter)
    elseif self.currentCause[prop] == cause then
        local newCause, newSetter = self:findNewMaxPriorityCause(prop)
        self:_set(prop, newCause, newSetter)
    end
end

function PropsS:_set(prop, cause, setter)
    if self._maid.isDestroyed then return end
    self._maid:Remove(prop)
    local setterMaid = setter(self.inst, prop)
    if setterMaid then self._maid:Add(setterMaid, "Destroy", prop) end
    self.currentCause[prop] = cause
end

function PropsS:removeCause(prop, oldCause)
    self.properties[prop] = self.properties[prop] or {}

    self.properties[prop][oldCause] = nil
    if next(self.properties[prop]) == nil then
        self.properties[prop] = nil
        self.currentCause[prop] = nil
    elseif self.currentCause[prop] == oldCause then
        local newCause, newSetter = self:findNewMaxPriorityCause(prop)
        self:_set(prop, newCause, newSetter)
    end
end

function PropsS:findNewMaxPriorityCause(prop)
    local newPriority = -math.huge
    local newCause, newSetter
    for _newCause, _newTbl in pairs(self.properties[prop]) do
        local _priority = tonumber(Codec.encoder[prop][_newCause])
        if _priority > newPriority then
            local _setter = unpack(_newTbl)
            newSetter = _setter
            newCause = _newCause
            newPriority = _priority
        end
    end
    return newCause, newSetter
end

function PropsS:setInClient(prop, cause, setterData, clients)
    local priority = tonumber(Codec.encoder[prop][cause])
    for _, client in ipairs(clients) do
        self.SetPropertyRE:FireClient(client, priority, setterData)
    end
end

function PropsS:removeCauseInClient(prop, cause, clients)
    local priority = tonumber(Codec.encoder[prop][cause])
    for _, client in ipairs(clients) do
        self.RemoveCauseRE:FireClient(client, priority)
    end
end

local id = 0
function PropsS:createRemotes()
    self.id = tostring(id)
    local eventsNames = {
        ("SetProperty_%s"):format(self.id),
        ("RemoveCause_%s"):format(self.id),
    }
    self._maid:Add(GaiaServer.createRemotes(PropsShared, {
        events = eventsNames,
    }))
    self.inst:SetAttribute("PropsId", self.id)
    id += 1
end

function PropsS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local isChar = CollectionService:HasTag(self.inst, "PlayerCharacter")
            if isChar then
                local player = PlayerUtils:GetPlayerFromCharacter(self.inst)
                if not player then return end
                local charId = self.char:GetAttribute("uid")
                self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
                if not self.charEvents then return end
            end
            return true
        end,
        keepTrying=function()
            return self.inst.Parent
        end,
    })
    return ok
end

function PropsS:Destroy()
    if self._maid.isDestroyed then return end
    self._maid:Destroy()
end

return PropsS