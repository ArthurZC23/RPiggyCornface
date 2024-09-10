local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})

local Maids = setmetatable({}, {__mode = "k"})
local Maid = {}
Maid.__index = Maid

local TypeDefaults = {
	["function"] = true;
	["RBXScriptConnection"] = "Disconnect";
}

function Maid.new()
	return setmetatable({CurrentlyCleaning = false}, Maid)
end

function Maid:Add2(Object, Index, MethodName)
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
        self[Object] = MethodName
    elseif TypeDefaults[typeof(Object)] then
        self[Object] = TypeDefaults[typeof(Object)]
    elseif typeof(Object) == "table" and Promise.is(Object) then
        self[Object] = "cancel"
    else
        self[Object] = "Destroy"
    end

	return Object
end

function Maid:Add(Object, MethodName, Index)
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
        self[Object] = MethodName
    elseif TypeDefaults[typeof(Object)] then
        self[Object] = TypeDefaults[typeof(Object)]
    elseif typeof(Object) == "table" and Promise.is(Object) then
        self[Object] = "cancel"
    else
        self[Object] = "Destroy"
    end

	return Object
end

function Maid:Remove(Index, kwargs)
    kwargs = kwargs or {}
    kwargs.debug = kwargs.debug or {}
	local this = Maids[self]

	if this then
		local Object = this[Index]

		if Object then
			local MethodName = self[Object]

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
				self[Object] = nil
			end

			this[Index] = nil
		end
	end
end

function Maid:RemoveNoExecution(Index)
	local this = Maids[self]

	if this then
        this[Index] = nil
	end
end

function Maid:Cleanup()
	if not self.CurrentlyCleaning then
		self.CurrentlyCleaning = nil -- A little trick to exclude the Debouncer from the loop below AND set it to true via __index :)

		for Object, MethodName in next, self do
			if MethodName == true then
				Object()
			else
				Object[MethodName](Object)
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

		self.CurrentlyCleaning = false
	end
end

function Maid:Destroy()
	self:Cleanup()
    self.isDestroyed = true
	setmetatable(self, nil)
end

return Maid