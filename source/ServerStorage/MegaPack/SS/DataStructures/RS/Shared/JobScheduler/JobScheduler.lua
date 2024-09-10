local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local Maid = Mod:find({"Maid"})
local FastSpawn = Mod:find({"FastSpawn"})
local Queue = Mod:find({"DataStructures", "Queue"})

local Schedulers = require(script.Parent.Schedulers)

local JobScheduler = {}
JobScheduler.__index = JobScheduler

function JobScheduler.new(jobHandler, schedulerType, kwargs)
	local self = {}
	setmetatable(self, JobScheduler)
	self.schedulerType = schedulerType or "standard"
	assert(Schedulers[self.schedulerType] ~= nil, ("Job Scheduler %s doesn't exist"):format(self.schedulerType))
	self.kwargs = kwargs or {}
	self._maid = Maid.new()
	self.jobQueue = self._maid:Add(Queue.new(unpack(self.kwargs.queueProps or {})))
	self.jobHandler = jobHandler
	self.executable = {}
	self.scheduler = Debounce.standard(Schedulers[self.schedulerType])

	self._maid:Add(function()
		self.executable = {}
	end)
	return self
end

function JobScheduler:pushJob(job)
	self.jobQueue:pushLeft(job)
	self.executable[job] = true
	FastSpawn(self.scheduler, self, self.kwargs.schedulerProps)
end

function JobScheduler:popJob(job)
	self.executable[job] = nil
	return job
end

function JobScheduler:getNumJobs()
	return self.jobQueue.size
end

function JobScheduler:Destroy()
	self._maid:Destroy()
end

return JobScheduler