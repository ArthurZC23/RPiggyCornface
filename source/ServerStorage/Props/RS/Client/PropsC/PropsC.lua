local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local Codec = Data.Props.PropsCodec

local PropsC = {}
PropsC.__index = PropsC
PropsC.className = "Props"
PropsC.TAG_NAME = PropsC.className

function PropsC.new(inst)
    local self = {
        _maid = Maid.new(),
        inst = inst,
        properties = {},
        currentCause = {},
    }
    setmetatable(self, PropsC)

    -- do
    --     local ok = self:getFields()
    --     if not ok then return end
    -- end
    -- self:handleRemotes()

    return self
end

function PropsC:createSetter(prop, setter)
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

function PropsC:getCurrentPriority(prop)
    local currentPriority
    if self.currentCause[prop] then
        currentPriority = tonumber(Codec.encoder[prop][self.currentCause[prop]])
    else
        currentPriority = Codec.NIL_CAUSE_PRIORITY
        self.currentCause[prop] = Codec.NIL_CAUSE
    end
    return currentPriority
end

function PropsC:addToPq(prop, cause, setter)
    self.properties[prop] = self.properties[prop] or {}
    local _setter = self:createSetter(prop, setter)
    self.properties[prop][cause] = {_setter}
    return _setter
end

function PropsC:set(prop, cause, setter)
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

function PropsC:_set(prop, cause, setter)
    if self._maid.isDestroyed then return end
    self._maid:Remove(prop)
    local setterMaid = setter(self.inst, prop)
    if setterMaid then self._maid:Add(setterMaid, "Destroy", prop) end
    self.currentCause[prop] = cause
    -- print(prop, cause, self.inst[prop])
end

function PropsC:removeCause(prop, oldCause)
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

function PropsC:findNewMaxPriorityCause(prop)
    local newPriority = -math.huge
    local newCause, newSetter
    for _newCause, _newTbl in pairs(self.properties[prop]) do
        -- print(prop, _newCause)
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

-- function PropsC:getFields()
--     local ok = SharedSherlock:find({"WaitFor", "Val"}, {
--         getter=function()
--             self.id = self.inst:GetAttribute("PropsId")
--             if not self.id then return end
--             self.SetPropertyRE = ComposedKey.getFirstDescendant(PropsRemotes, {"Events", ("SetProperty_%s"):format(self.id)})
--             self.RemoveCauseRE = ComposedKey.getFirstDescendant(PropsRemotes, {"Events", ("RemoveCause_%s"):format(self.id)})
--             if not (self.SetPropertyRE and self.RemoveCauseRE) then return end

--             return true
--         end,
--         keepTrying=function()
--             return self.inst.Parent
--         end,
--     })
--     return ok
-- end

-- function PropsC:handleRemotes()
--     local function buildSetter(prop, setterData)
--         assert(typeof(setterData) == "number" or typeof(setterData) == "table", ("Invalid setterData %s"):format(tostring(setterData)))
--         if typeof(setterData) == "number" then
--             return function()
--                 self.inst[prop] = setterData
--             end
--         elseif typeof(setterData) == "table" then
--             if setterData.t == "t" then
--                 return function()
--                     local tweenInfo = TweenInfo.new(unpack(setterData.i))
--                     local goal = {prop = setterData.g}
--                     local tween = TweenService:Create(self.inst, tweenInfo, goal)
--                     tween:Play()
--                     if setterData.m == "s" then
--                         return function ()
--                             tween:Stop()
--                         end
--                     elseif setterData.m == "p" then
--                         return function ()
--                             tween:Pause()
--                         end
--                     else
--                         error(("Invalid tween setter maid %s"):format(tostring(setterData.m)))
--                     end
--                 end
--             else
--                 error(("Invalid setterData table type %s"):format(tostring(setterData.t)))
--             end
--         end
--     end
--     self._maid:Add(self.SetPropertyRE.OnClientEvent:Connect(function(priority, setterData)
--         local prop, cause = unpack(Codec.decoder[priority])
--         local setter = buildSetter(prop, setterData)
--         self:set(prop, cause, setter)
--     end))
--     self._maid:Add(self.RemoveCauseRE.OnClientEvent:Connect(function(priority)
--         local prop, cause = unpack(Codec.decoder[priority])
--         self:removeCause(prop, cause)
--     end))
-- end

function PropsC:Destroy()
    if self._maid.isDestroyed then return end
    self._maid:Destroy()
end

return PropsC