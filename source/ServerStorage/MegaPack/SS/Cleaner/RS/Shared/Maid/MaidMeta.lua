local RootFolder = script:FindFirstAncestor("Maid")

local Cleanup = require(RootFolder.Cleanup)

local MaidMeta = {}

function MaidMeta:__index(index)
	if MaidMeta[index] then
		return MaidMeta[index]
	else
		return self._tasks[index]
	end
end

function MaidMeta:__newindex(index, newTask)
	if MaidMeta[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		Cleanup.cleanup(oldTask)
	end
end

return MaidMeta