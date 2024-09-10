local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)

local Sherlock = {}
Sherlock.__index = Sherlock
Sherlock.__call = Sherlock.find
Sherlock.className = "Sherlock"

function Sherlock.new(searchSpace, sherlockKwargs)
	local self = {}
	setmetatable(self, Sherlock)
	self.sherlockKwargs = sherlockKwargs or {}
	self.searchSpace = searchSpace
	return self
end

function Sherlock:addToSearchSpace(composedKey, callback)
    ComposedKey.set(self.searchSpace, composedKey, callback)
end

-- Memoization should not be available as a parameter of client or be the resposability of sherlock.
-- Let the functions memoize themselves.
function Sherlock:find(clues, kwargs)
    local getter = ComposedKey.get(self.searchSpace, clues)
    return getter(kwargs, self.sherlockKwargs, self.searchSpace, clues)
end

function Sherlock:getGetter(clues, kwargs)
    local getter = ComposedKey.get(self.searchSpace, clues)
    return getter
end

function Sherlock:Destroy()

end

return Sherlock