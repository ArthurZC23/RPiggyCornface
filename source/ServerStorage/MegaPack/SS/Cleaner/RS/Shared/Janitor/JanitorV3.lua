local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})
local IdUtils = Mod:find({"Id", "Utils"})

local idGenerator = IdUtils.limitedIdGenerator("1", tostring(1e12))

local Maids = setmetatable({}, {__mode = "k"})
local Maid = {}
Maid.__index = Maid
Maid.className = "Maid"

local TypeDefaults = {
	["function"] = true;
	["RBXScriptConnection"] = "Disconnect";
}

function Maid.new(kwargs)
    kwargs = kwargs or {}
    local self = {
        isCleaning = false,
        id = idGenerator(),
        jobs = {},
        debug = kwargs.debug or {},
    }
    setmetatable(self, Maid)
	return self
end

function Maid.__index:Add2(Object, Index, MethodName)
	if Index then
		self:Remove(Index)

		local this = Maids[self]

		if not this then
			this = {}
			Maids[self] = this
		end

		this[Index] = Object
	end

    if MethodName then
        self.jobs[Object] = MethodName
    elseif TypeDefaults[typeof(Object)] then
        self.jobs[Object] = TypeDefaults[typeof(Object)]
    elseif typeof(Object) == "table" and Promise.is(Object) then
        self.jobs[Object] = "cancel"
    else
        self.jobs[Object] = "Destroy"
    end

	return Object
end

function Maid.__index:Add(Object, MethodName, Index)
	if Index then
		self:Remove(Index)

		local this = Maids[self]

		if not this then
			this = {}
			Maids[self] = this
		end

		this[Index] = Object
	end

    if MethodName then
        self.jobs[Object] = MethodName
    elseif TypeDefaults[typeof(Object)] then
        self.jobs[Object] = TypeDefaults[typeof(Object)]
    elseif typeof(Object) == "table" and Promise.is(Object) then
        self.jobs[Object] = "cancel"
    else
        self.jobs[Object] = "Destroy"
    end

	return Object
end

function Maid.__index:Remove(Index, kwargs)
    kwargs = kwargs or {}
    kwargs.debug = kwargs.debug or {}
	local this = Maids[self]

	if this then
		local Object = this[Index]

		if Object then
			local MethodName = self.jobs[Object]

            if kwargs.debug.printMethod then
                print(MethodName)
                TableUtils.print(Object)
            end
			if MethodName then
				if MethodName == true then
					Object()
				else
					Object[MethodName](Object)
				end
				self.jobs[Object] = nil
			end

			this[Index] = nil
		end
	end
end

function Maid.__index:RemoveNoExecution(Index)
	local this = Maids[self]

	if this then
        this[Index] = nil
	end
end

function Maid.__index:Cleanup()
	if not self.isCleaning then
		self.isCleaning = true

		for Object, MethodName in pairs(self.jobs) do
            local typeof_ = typeof(Object)
            if typeof_ == "function" then
				Object()
			elseif typeof_ == "table" then
                if Object[MethodName] then
				    Object[MethodName](Object)
                else
                    local traceback = debug.traceback(nil, 2)
                    task.spawn(function()
                        error(("Table %s doesn't have method %s.\n%s"):format(TableUtils.stringify(Object), MethodName, traceback))
                    end)
                end
            elseif typeof_ == "Instance" then
                Object[MethodName](Object)
            else
                local traceback = debug.traceback(nil, 2)
                task.spawn(function()
                    error(("Unsuported type %s for Janitor\n%s."):format(typeof_, traceback))
                end)
			end
			self[Object] = nil
		end

		local this = Maids[self]

		if this then
			for Index in next, this do
				this[Index] = nil
			end
			Maids[self] = nil
		end

        self.isDestroyed = true
        setmetatable(self, nil)
		self.isCleaning = false
	end
end

function Maid.__index:Destroy()
    if self.debug.destroy then
        print(debug.traceback(nil, 2))
    end
	self:Cleanup()
end

return Maid