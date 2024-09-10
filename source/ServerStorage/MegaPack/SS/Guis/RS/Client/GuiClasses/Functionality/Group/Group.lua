local Group = {}
Group.__index = Group

function Group.new(guiObjs, personalModifiers, sharedModifiers)
    local self = {}
    setmetatable(self, Group)
    for i, obj in ipairs(guiObjs) do
        local pModifiers = personalModifiers[i]
        if typeof(pModifiers) == "table" then
			for _, mod in ipairs(pModifiers) do
				if typeof(mod[1]) == "table" and mod[1].new then
	                local class = mod[1]
					class.new(obj, unpack(mod, 2, #mod))
				elseif typeof(mod[1]) == "function" then
					mod[1](unpack(mod, 2, #mod))
				else
					error("Personal modifier argument #1 need to be class or function.")
				end	
			end
		end
		if typeof(sharedModifiers) == "table" then
	        for _, mod in ipairs(sharedModifiers) do
				if typeof(mod[1]) == "table" and mod[1].new then
					local class = mod[1]
					class.new(obj, unpack(mod, 2, #mod))
				elseif typeof(mod[1]) == "function" then
					mod[1](unpack(mod, 2, #mod))
				else
					error("Personal modifier argument #1 need to be class or function.")
				end	    
			end
		end
    end
    return self
end

return Group