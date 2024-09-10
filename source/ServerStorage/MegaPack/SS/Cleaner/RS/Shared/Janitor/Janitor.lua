local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Promise = require(ReplicatedStorage.Promise.Shared.Promise:Clone())
local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)

local Maids = setmetatable({}, {__mode = "k"})
local Maid = {}
Maid.__index = Maid
Maid.className = "Maid"

local strings = {
    ["Destroyed"] = "Maid id:\n\n%s\n\nMaid was already destroyed. Cannot call method %s.\n\n Traceback: %s"
}

local TypeDefaults = {
	["function"] = true;
	["RBXScriptConnection"] = "Disconnect";
}

local function reportError(err)
    local traceback = debug.traceback(nil, 2)
    task.spawn(function()
        error(("%s\n\n%s"):format(err, traceback))
    end)
end

function Maid.new(kwargs)
    kwargs = kwargs or {}
    local self = {
        id = ("%s %s %s"):format(debug.info(2, "sln")),
        jobs = {},
        debug = kwargs.debug or {},
    }
    if kwargs.id then
        self.id = ("%s_%s"):format(kwargs.id, self.id)
    end
    setmetatable(self, Maid)
	return self
end

function Maid.__index:AddWithTimeout(Object, Index, timeout, kwargs)
    kwargs = kwargs or {}
    local MethodName = kwargs.methodName
    local maid = Maid.new()
    maid:Add2(Object, Index, MethodName, kwargs)
    maid:Add2(Promise.delay(timeout):andThen(function()
        maid:Remove(Index)
        reportError(("Maid id:\n\n%s\n\nMaid Index %s timeout after %s."):format(self.id, Index, timeout))
    end))

    self:Add2(maid, Index, MethodName, kwargs)
    return Object
end

function Maid.__index:AddPromiseTimeout(promise, timeout, Index, MethodName, kwargs)
    self:Add2(function()
        task.delay(timeout, function()
            promise:cancel()
        end)
    end, Index, MethodName, kwargs)
    return promise
end

function Maid.__index:Add2(Object, Index, MethodName, kwargs)
    if Index then
        assert(typeof(Index == "string"))
    end
    if self.isDestroyed then
        reportError((strings.Destroyed):format(self.id, "Add2", self.destroyTraceback))
        return
    end
    kwargs = kwargs or {}
    if kwargs.debug then
        local traceback = debug.traceback(nil, 2)
        print(("Add\nObject %s\nIndex %s\nMethod name %s to maid.\n%s"):format(tostring(Object), tostring(Index), tostring(MethodName), traceback))
    end
	if Index then
		self:Remove(Index)

		local this = Maids[self]

		if not this then
			this = {}
			Maids[self] = this
		end

		this[Index] = Object
	end

    local _type = typeof(Object)
    if MethodName then
        self.jobs[Object] = MethodName
    elseif TypeDefaults[_type] then
        self.jobs[Object] = TypeDefaults[_type]
    elseif _type == "table" and Promise.is(Object) then
        self.jobs[Object] = "cancel"
    elseif (_type == "table" and Object.Destroy) or _type == "Instance" then
        self.jobs[Object] = "Destroy"
    else
        error(("Object %s type %s cannot be added to Maid."):format(tostring(Object), _type))
    end

	return Object
end

function Maid.__index:TryToAdd(Object, ...)
    return self:AddComponent(Object, ...)
end

function Maid.__index:AddComponent(Object, ...)
    if Object == nil then return end
    return self:Add2(Object, ...)
end

function Maid.__index:Add(Object, MethodName, Index, kwargs)
    return self:Add2(Object, Index, MethodName, kwargs)
end

function Maid.__index:Remove(Index, kwargs)
    if self.isDestroyed then
        return
    end
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

function Maid.__index:RemoveWithoutExecution(Index, kwargs)
    if self.isDestroyed then
        reportError((strings.Destroyed):format(self.id, "RemoveWithoutExecution", self.destroyTraceback))
        return
    end
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
				self.jobs[Object] = nil
			end

			this[Index] = nil
		end
	end
end

-- Don't use it.
-- This method doesn't work with jobs.
function Maid.__index:RemoveNoExecution(Index)
    if self.isDestroyed then
        reportError((strings.Destroyed):format(self.id, "RemoveNoExecution", self.destroyTraceback))
        return
    end
	local this = Maids[self]

	if this then
        this[Index] = nil
	end
end

local function _pcall(func, ...)
    local args = {...}
    local ok, err = xpcall(
        function()
            return func(unpack(args))
        end,
        function(err)
            local _err = (("Error:\n%s\n\nTraceback:\n%s"):format(err, debug.traceback()))
            reportError(_err)
            return false, err
        end
    )
end

function Maid.__index:Cleanup()
    if self.isDestroyed then
        -- reportError((strings.Destroyed):format(self.id, "Cleanup", self.destroyTraceback))
        return
    end
    self.isDestroyed = true
    self.destroyTraceback = debug.traceback(nil, 2)

    for Object, MethodName in pairs(self.jobs) do
        local typeof_ = typeof(Object)
        if MethodName == true then
            if typeof_ == "function" then
                _pcall(Object)
            elseif typeof_ == "table" then
                local mt = getmetatable(Object)
                if typeof(mt.__call) == "function" then
                    _pcall(Object)
                end
            else
                task.spawn(function()
                    if typeof_ == "table" then
                        reportError(("Maid id:\n\n%s\n\n%s is not callable.\n%s"):format(self.id, tostring(Object), TableUtils.stringify(Object)))
                    else
                        reportError(("Maid id:\n\n%s\n\n%s is not callable."):format(self.id, tostring(Object)))
                    end
                end)
            end
        else
            if (typeof_ == "Instance" or typeof_ == "table" or typeof_ == "RBXScriptConnection") and Object[MethodName] then
                _pcall(Object[MethodName], Object)
            elseif not (typeof_ == "Instance" or typeof_ == "table" or typeof_ == "RBXScriptConnection") then
                reportError(("Maid id:\n\n%s\n\nCannot index %s %s with %s."):format(self.id, tostring(Object), typeof_, tostring(MethodName)))
            else
                reportError(("Maid id:\n\n%s\n\nTable %s doesn't have method %s.\n%s"):format(self.id, tostring(Object), tostring(MethodName), TableUtils.stringify(Object)))
            end
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
end

function Maid.__index:Destroy()
    if self.debug.destroy then
        print(debug.traceback(nil, 2))
    end
	self:Cleanup()
end

return Maid