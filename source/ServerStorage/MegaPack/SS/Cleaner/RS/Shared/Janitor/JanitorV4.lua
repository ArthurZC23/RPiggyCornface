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

local function reportError(err, instancingTraceback)
    local traceback = debug.traceback(nil, 2)
    task.spawn(function()
        if instancingTraceback then
            error(("%s\n%s\n%s"):format(err, traceback, instancingTraceback))
        else
            error(("%s\n%s"):format(err, traceback))
        end
    end)
end

local addInstancingTraceback = false
function Maid.new(kwargs)
    kwargs = kwargs or {}
    local self = {
        id = idGenerator(),
        jobs = {},
        debug = kwargs.debug or {},
    }
    if addInstancingTraceback then
        self.debug.instancingTraceback = ("Instancing Traceback:\n%s"):format(debug.traceback(nil, 2))
    end
    if kwargs.id then
        self.id = ("%s_%s"):format(kwargs.id, self.id)
    end
    setmetatable(self, Maid)
	return self
end

function Maid.__index:Add2(Object, Index, MethodName, kwargs)
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
        reportError(("Maid %s. Maid was already destroyed. Cannot call method."):format(self.id), self.debug.instancingTraceback)
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
        reportError(("Maid %s. Maid was already destroyed. Cannot call method."):format(self.id), self.debug.instancingTraceback)
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

function Maid.__index:RemoveNoExecution(Index)
    if self.isDestroyed then
        reportError(("Maid %s. Maid was already destroyed. Cannot call method."):format(self.id), self.debug.instancingTraceback)
        return
    end
	local this = Maids[self]

	if this then
        this[Index] = nil
	end
end

local function _pcall(func, instancingTraceback, ...)
    local ok, err = pcall(func, ...)
    if not ok then reportError(err, instancingTraceback) end
end

function Maid.__index:Cleanup()
    if self.isDestroyed then
        reportError(("Maid %s. Maid was already destroyed. Cannot call method."):format(self.id), self.debug.instancingTraceback)
        return
    end
    self.isDestroyed = true

    for Object, MethodName in pairs(self.jobs) do
        local typeof_ = typeof(Object)
        if MethodName == true then
            if typeof_ == "function" then
                _pcall(Object, self.debug.instancingTraceback)
            elseif typeof_ == "table" then
                local mt = getmetatable(Object)
                if typeof(mt.__call) == "function" then
                    _pcall(Object, self.debug.instancingTraceback)
                end
            else
                task.spawn(function()
                    if typeof_ == "table" then
                        reportError(("Maid %s. %s is not callable.\n%s"):format(self.id, tostring(Object), TableUtils.stringify(Object)), self.debug.instancingTraceback)
                    else
                        reportError(("Maid %s. %s is not callable."):format(self.id, tostring(Object)), self.debug.instancingTraceback)
                    end
                end)
            end
        else
            if (typeof_ == "Instance" or typeof_ == "table" or typeof_ == "RBXScriptConnection") and Object[MethodName] then
                _pcall(Object[MethodName], self.debug.instancingTraceback, Object)
            elseif not (typeof_ == "Instance" or typeof_ == "table" or typeof_ == "RBXScriptConnection") then
                reportError(("Maid %s. Cannot index %s %s with %s."):format(self.id, tostring(Object), typeof_, tostring(MethodName)), self.debug.instancingTraceback)
            else
                reportError(("Maid %s. Table %s doesn't have method %s.\n%s"):format(self.id, tostring(Object), tostring(MethodName), TableUtils.stringify(Object)), self.debug.instancingTraceback)
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