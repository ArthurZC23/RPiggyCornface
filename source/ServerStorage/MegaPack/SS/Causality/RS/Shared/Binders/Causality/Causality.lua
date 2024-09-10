local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local IdUtils = Mod:find({"Id", "Utils"})

local Causality = {}
Causality.__index = Causality
Causality.className = "Causality"
Causality.TAG_NAME = Causality.className

function Causality.new(inst)
    local self = {
        inst = inst,
        _maid = Maid.new(),
        effects = {},
        priorities = {
            "Low",
            "Medium",
            "High",
        },
        idGenerator = IdUtils.createNumIdGenerator(),
    }
    setmetatable(self, Causality)

    return self
end

function Causality:addEffect(cause, effect, priority)
    if not self.effects[cause] then self:_createCauseEffectsPriorityMap(cause) end
    priority = priority or "Low"
    assert(self.effects[cause][priority], ("Invalid priority %s"):format(priority))
    local id = self.idGenerator()
    self.effects[cause][priority][id] = effect
    return function()
        self:removeEffect(cause, priority, id)
    end
end

function Causality:removeEffect(cause, priority, id)
    if not self.effects[cause] then return end
    assert(self.effects[cause][priority], ("Invalid priority %s"):format(priority))
    self.effects[cause][priority][id] = nil
end

function Causality:hasEffect(cause)
    return (self.effects[cause] ~= nil)
end

function Causality:_createCauseEffectsPriorityMap(cause)
    self.effects[cause] = {}
    for _, priority in ipairs(self.priorities) do
        self.effects[cause][priority] = {}
    end
end

function Causality:runEffects(cause, kwargs)
    kwargs = kwargs or {}
    if RunService:IsStudio() then
        kwargs.trace = debug.traceback(nil, 2)
    end
    local promise = Promise.try(function()
        assert(cause, "Cause cannot be nil.")
        local effects = self.effects[cause]
        if not effects then return end
        for _, priority in ipairs(self.priorities) do
            local effectsByPriority = effects[priority]
            for effectId, effect in pairs(effectsByPriority) do
                task.spawn(effect.callback, unpack(effect.args), kwargs)
            end
        end
    end)
    return promise
end

function Causality:Destroy()
    self._maid:Destroy()
end

return Causality