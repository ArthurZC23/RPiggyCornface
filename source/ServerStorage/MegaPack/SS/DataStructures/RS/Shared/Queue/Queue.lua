local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local Mts = Mod:find({"Table", "Mts"})

local RootF = script.Parent
local FullQueueHandlers = require(RootF.FullQueueHandlers)
local QueueTypes = require(RootF.QueueTypes)

local Queue = {}
Queue.__index = Queue

Queue.CreationMethods = {
	Reference = "Reference",
	ShallowCopy = "ShallowCopy",
	DeepCopy = "DeepCopy",
}

Queue.CreationMethods = Mts.makeEnum("QueueCreationMethods", Queue.CreationMethods)
Queue.FullQueueHandlers = Mts.makeEnum("FullQueueHandlers", FullQueueHandlers)
Queue.QueueTypes = Mts.makeEnum("QueueTypes", QueueTypes)

local function createQueue(array, creationMethod)
	if not array then return {} end
	creationMethod = creationMethod or "Reference"
	if creationMethod == "Reference" then
		return array
	elseif creationMethod == "ShallowCopy" then
		return TableUtils.shallowCopy(array)
	elseif creationMethod == "DeepCopy" then
		return TableUtils.deepCopy(array)
	else
		error(("Queue creation method %s is not supported"):format(creationMethod), 3)	
	end
end

function Queue.new(array, kwargs)
    local self = {}
	setmetatable(self, Queue)
	self.kwargs = kwargs or {}
	self._queue = createQueue(array)
	self.maxSize = self.kwargs.maxSize or math.huge
	if self.maxSize == math.huge then
		self.fullQueueHandler = Queue.FullQueueHandlers.Infinite
	else
		self.fullQueueHandler = self.kwargs.fullQueueHandler
	end
	
	self.queueType = self.kwargs.queueType or Queue.QueueTypes.FirstLastIdxs
	
	self.pushLeft = self.fullQueueHandler.pushLeft(self.queueType.pushLeft)
	self.pushRight = self.fullQueueHandler.pushRight(self.queueType.pushRight)
	self.popLeft = self.fullQueueHandler.popLeft(self.queueType.popLeft)
	self.popRight = self.fullQueueHandler.popLeft(self.queueType.popRight)
	
    self.first = 1
    self.last = #self._queue
    self.size = #self._queue
    return self
end

function Queue:find(key)
    return table.find(self._queue, key)
end

function Queue:remove(key)
    local idx = table.find(self._queue, key)
    table.remove(self._queue, idx)
end

function Queue:print()
	TableUtils.print(self._queue, ("Queue %s"):format(self.name))
end

function Queue:Destroy()
	self._queue = nil
end

return Queue