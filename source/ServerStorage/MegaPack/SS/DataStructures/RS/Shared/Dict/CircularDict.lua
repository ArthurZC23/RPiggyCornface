local CircularDict = {}
CircularDict.__index = CircularDict

function CircularDict.new(dict)
	local self = {}
	setmetatable(self, CircularDict)
	self._dict = dict
	self.lastKey = nil
	return self
end

function CircularDict:get(key)
	return self._dict[key]
end

function CircularDict:set(key, val)
	self._dict[key] = val
end

function CircularDict:next()
	if not next(self._dict) then
		return
	end

	local key, val = next(self._dict, self.lastKey)
	self.lastKey = key

	return key, val
end

function CircularDict:Destroy()

end

return CircularDict