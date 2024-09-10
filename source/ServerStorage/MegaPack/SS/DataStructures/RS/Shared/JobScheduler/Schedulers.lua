local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local module = {}

function module.standard(self)
	while self.jobQueue.size > 0 do
		local job = self.jobQueue:popRight()
		if self.executable[job] then
			self.jobHandler(job)
		end
	end
end

function module.cooldown(self, kwargs)
	while self.jobQueue.size > 0 do
		local job = self.jobQueue:popRight()
		if self.executable[job] then
			self.jobHandler(job)
		end
		local ok, err = Promise.delay(kwargs.cooldownFunc()):await()
		if not ok then warn(tostring(err)) end
	end
end

return module