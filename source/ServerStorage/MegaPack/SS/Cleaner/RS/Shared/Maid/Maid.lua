local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local RootFolder = script:FindFirstAncestor("Maid")

local Cleanup = require(RootFolder.Cleanup)
local MaidMeta = require(RootFolder.MaidMeta)

local Maid = {}
Maid.ClassName = "Maid"

function Maid.new()
    local self = {
        _tasks = {}
    }
    setmetatable(self, MaidMeta)
    return self
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

function Maid:giveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	if type(task) == "table" and (not task.Destroy) then
		error("[Maid.giveTask] - Gave table task without Destroy method\n" .. debug.traceback(), 2)
	end

	if Promise.isPromise(task) then
		error("Maid are not handling Promises yet.", 2)
		return self:_givePromise(task)
	else
		return self:_giveTask(task)
	end
end

function Maid:_giveTask(task)
	local taskId = #self._tasks + 1
	self[taskId] = task

	return taskId
end

function Maid:_givePromise(promise)
	if not promise:getStatus() == Promise.Status.Started  then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

function Maid:cleanup()
	local tasks = self._tasks

	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		Cleanup.cleanup(task)
		index, task = next(tasks)
	end
end

return Maid