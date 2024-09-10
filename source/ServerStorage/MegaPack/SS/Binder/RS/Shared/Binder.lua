local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local Maid = Mod:find({"Maid"})
local SignalE = Mod:find({"Signal", "Event"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})

local Utils = require(script.Parent.BinderUtils)

local Binder = {}
Binder.__index = Binder
Binder.className = "Binder"

function Binder.new(tagName, Class, classModulePath)
    assert(
        typeof(tagName) == "string",
        ("Bad argument 'tagName' %s. Expected string"):format(typeof(tagName))
    )
    assert(
        typeof(Class) == "table" and Class.new,
        ("Bad argument 'Class' %s. Expected Class table"):format(tagName)
    )
	local self = setmetatable({
        _maid = Maid.new(),
        _classModulePath = classModulePath,
        _tagName = tagName,
        _instToObj = {},
        _Class = Class,
        _getters = {},
        classBinderConfig = Class.binderConfig or {},
        _pendingInstSet = {},
        _listeners = {},
    }, Binder)

    do
        if not Class.__string then
            Class.__tostring = function()
                return Class.className
            end
        end
    end
    self.gettersConfig = self.classBinderConfig or {}
    self.gettersData = self.gettersConfig.getters or {}
    for _, gettersData in ipairs(self.gettersData) do
        self._getters[gettersData.name] = {}
    end

    self.load = Debounce.oneExecution(self.load)
    -- Should I load in a separate step? Yes. I may want to add event listeners and callbacks before loading.
    --self:load()

	return self
end


function Binder:load()
    do
        local event = CollectionService:GetInstanceRemovedSignal(self._tagName)
        self._maid:Add(event:Connect(function(inst) self:_remove(inst) end))
    end
    do
        local event = CollectionService:GetInstanceAddedSignal(self._tagName)
        self._maid:Add(event:Connect(function(inst)
            -- game has Parent == nil
            if inst.Parent == nil and inst ~= game then
                task.spawn(function()
                    if RunService:IsClient() then return end
                    local str1 = "CollectionService:GetInstanceAddedSignal"
                    local str2 = ("Binder %s: inst %s already has Parent = nil"):format(self._tagName, inst:GetFullName())
                    local str = table.concat({str1, str2}, "\n\n")
                    error(str)
                end)
                return
            end
            self:_add(inst)
        end))
    end
    for _, inst in pairs(CollectionService:GetTagged(self._tagName)) do
        Promise.try(function()
            if inst.Parent == nil and inst ~= game then
                task.spawn(function()
                    if RunService:IsClient() then return end
                    local str1 = "CollectionService:GetTagged"
                    local str2 = ("Binder %s: inst %s already has Parent = nil"):format(self._tagName, inst:GetFullName())
                    local str = table.concat({str1, str2}, "\n\n")
                    error(str)
                end)
            end
            self:_add(inst)
        end)
        :myCatch({reportError = true})
    end
end

function Binder:_add(inst)
	assert(typeof(inst) == "Instance", "Argument 'inst' is not an Instance")

	if self._instToObj[inst] then
		-- Avoid running two times when instance is tagged in the same frame is created.
		-- https://devforum.roblox.com/t/double-firing-of-collectionservice-getinstanceaddedsignal-when-applying-tag/244235
		return
	end

	if self._pendingInstSet[inst] == true then
		warn("[Binder._add] - Reentered add. Still loading, probably caused by error in constructor or yield.")
		warn(("Class: %s, Instance: %s"):format(self._Class.className, inst:GetFullName()))
		return
	end
	self._pendingInstSet[inst] = true

    local obj = self._Class.new(inst)

    if not obj then
        self._pendingInstSet[inst] = nil
        return
    end

	if self._pendingInstSet[inst] ~= true then
		warn(("[Binder._add] - Failed to load instance %q of Class %q of Tag %q, removed while loading!")
			:format(
				inst:GetFullName(),
                self._tagName,
                self._classModulePath
			))
		if obj and obj.Destroy then
			obj:Destroy()
		else
			warn(("[Binder._add] - Class %s no longer has :Destroy."):format(tostring(self._tagName)))
		end
		return -- Need to destroy the obj
	end
	self._pendingInstSet[inst] = nil

	if not (type(obj) == "table" and type(obj.Destroy) == "function") then
		error(("[Binder._add] - Class %s has a bad constructor"):format(self._tagName))
		return
	end

	assert(
        self._instToObj[inst] == nil,
        ("Instance %s has already binded to class %s"):format(inst:GetFullName(), self._tagName)
    )

	-- Add to state
    self:_addRepresentations(inst, obj)

	-- This code should not yield? 
    for _, gettersData in ipairs(self.gettersData) do
        local key = gettersData.getComposedKey(inst, obj)
        local val = gettersData.getValue(inst, obj)
        ComposedKey.set(self._getters[gettersData.name], key, val)
    end

	self:_runCallbacks(inst, obj)

	if self._objAddedSignal then self._objAddedSignal:Fire(obj, inst) end
end

function Binder:_addRepresentations(inst, obj)
    self.classBinderConfig.representations = self.classBinderConfig.representations or {}
	self._instToObj[inst] = obj
    if self.classBinderConfig.representations.objArray then
        self._objArraySize = self._objArraySize or 0
        self._objArrayIdx = self._objArrayIdx or {}
        self._objArray = {}

        table.insert(self._objArray, obj)
        self._objArraySize += 1
        self._objArrayIdx[inst] = self._objArraySize
    end
end

function Binder:_runCallbacks(inst, obj)
    local listeners = self._listeners[inst] or {}
    for callback, _ in pairs(listeners) do
        Promise.try(function()
            callback(obj)
        end)
        :myCatch({reportError = true})
    end
end

function Binder:_remove(inst)
	self._pendingInstSet[inst] = nil

	local obj = self._instToObj[inst]
	if obj == nil then return end

    self:_runCallbacks(inst, nil)

	if self._objRemovingSignal then self._objRemovingSignal:Fire(obj, inst) end

    self:removeRepresentations(inst, obj)
	self._instToObj[inst] = nil
    for _, gettersData in ipairs(self.gettersData) do
        local key = gettersData.getComposedKey(inst, obj)
        ComposedKey.set(self._getters[gettersData.name], key, nil)
    end

	-- Destroy obj
	if obj.Destroy then
		obj:Destroy()
	else
		warn(("[Binder._remove] - Class %s no longer has :Destroy."):format(tostring(self._tagName)))
	end
end

function Binder:removeRepresentations(inst)
    self.classBinderConfig.representations = self.classBinderConfig.representations or {}
	self._instToObj[inst] = nil
    if self.classBinderConfig.representations.objArray then
        local idx = self._objArrayIdx[inst]
        table.remove(self._objArray, idx)
        self._objArraySize -= 1
    end
end

function Binder:bindClient(inst)
	if not RunService:IsClient() then
		error(("[Binder.BindClient] - Bindings '%s' done on the server. Use Binder.bind instead.")
            :format(self._tagName)
        )
    end
    assert(typeof(inst) == "Instance")

	CollectionService:AddTag(inst, self._tagName)
	return self:getObj(inst)
end

function Binder:unbindClient(inst)
    if not RunService:IsClient() then
		error(("[Binder.BindClient] - Bindings '%s' done on the server. Use Binder.bind instead.")
			:format(self._tagName))
    end

	assert(typeof(inst) == "Instance")
	CollectionService:RemoveTag(inst, self._tagName)
end

function Binder:getObj(inst)
	assert(typeof(inst) == "Instance", "Argument 'inst' is not an Instance")
	return self._instToObj[inst]
end

function Binder:getObjAsync(inst, keepTrying, cd)
    keepTrying = keepTrying or function() return true end
	return Promise.try(function()
        return SharedSherlock:find({"WaitFor", "Val"}, {
            getter=function()
                return self:getObj(inst)
            end,
            keepTrying=keepTrying,
            cooldown=cd or 1 / 60,
        })
    end)
end

function Binder:getClass()
    return self._Class
end

function Binder:getTag()
	return self._tagName
end

function Binder:getObjectsArray()
	local objs = {}
    for _, obj in pairs(self._instToObj) do table.insert(objs, obj) end
	return objs
end

function Binder:getInstToObj()
    return self._instToObj
end

function Binder:observeInstance(inst, callback) -- For a subset of all binded instances.
	self._listeners[inst] = self._listeners[inst] or {}
	self._listeners[inst][callback] = true

    -- For a cleaner
	return function()
		if not self._listeners[inst] then
			return
		end

		self._listeners[inst][callback] = nil
		if not next(self._listeners[inst]) then
			self._listeners[inst] = nil
		end
	end
end

function Binder:getClassAddedSignal() -- For all binded instances.
	if self._objAddedSignal then
		return self._objAddedSignal
	end

	self._objAddedSignal = SignalE.new() -- :Fire(obj, inst)
	self._maid:Add(self._objAddedSignal)
	return self._objAddedSignal
end

function Binder:getClassRemovingSignal()
	if self._objRemovingSignal then
		return self._objRemovingSignal
	end

	self._objRemovingSignal = SignalE.new() -- :Fire(obj, inst)
	self._maid:Add(self._objRemovingSignal)

	return self._objRemovingSignal
end

function Binder:getGetter(getterName)
    return self._getters[getterName]
end

function Binder:Destroy()
	local index, obj = next(self._instToObj)
	while obj ~= nil do
		self:_remove(obj)
		assert(self._instToObj[index] == nil)
	end

	self._maid:Destroy()
end

Binder.Utils = Utils

return Binder