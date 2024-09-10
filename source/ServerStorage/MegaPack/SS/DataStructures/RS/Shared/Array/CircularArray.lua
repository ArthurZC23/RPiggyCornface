local CircularArray = {}
CircularArray.__index = CircularArray

function CircularArray.new(array)
	local self = {}
	setmetatable(self, CircularArray)
	self._array = array
    self.size = #array
    self.lastIdx = 1
	return self
end

function CircularArray:get(idx)
	return self._array[idx]
end

function CircularArray:set(idx, val)
	if idx < 1 or idx > #self._array + 1 then
		error(("Index %s is not within array range."):format(idx), 2)
	end
	self._array[idx] = val
end

function CircularArray:insert(val)
	table.insert(self._array, val)
    self.size += 1
end

function CircularArray:next(step)
    if not next(self._array) then
		return
	end

    step = step or 1
    assert(step >= 0, "Step cannot be negative.")

    -- print(":next circular array")
    -- print(("Step: %s"):format(step))

    -- print("Before")
    -- print(("lastIdx: %s"):format(self.lastIdx))

    if step > self.size then
        step = step % self.size
    end

    self.lastIdx = self.lastIdx + step
    if self.lastIdx > self.size then
        self.lastIdx = self.lastIdx - self.size
        -- print("After 1")
        -- print(("lastIdx: %s"):format(self.lastIdx))
        return self.lastIdx, self._array[self.lastIdx]
    end
    -- print("After 2")
    -- print(("lastIdx: %s"):format(self.lastIdx))
    return self.lastIdx, self._array[self.lastIdx]
end

function CircularArray:previous(step)
	if not next(self._array) then
		return
	end

    step = step or 1
    assert(step > 0, "Step cannot be negative.")

    -- print(":previous circular array")
    -- print(("Step: %s"):format(step))

    -- print("Before")
    -- print(("lastIdx: %s"):format(self.lastIdx))

    if step > self.size then
        step = step % self.size
    end

    self.lastIdx = self.lastIdx - step
    if self.lastIdx < 1 then
        self.lastIdx = (self.size + 1) - step
        -- print("After 1")
        -- print(("lastIdx: %s"):format(self.lastIdx))
        return self.lastIdx, self._array[self.lastIdx]
    end
    -- print("After 2")
    -- print(("lastIdx: %s"):format(self.lastIdx))
    return self.lastIdx, self._array[self.lastIdx]
end

function CircularArray:current()
	if not next(self._array) then
		return
	end
    if not self.lastIdx then return end
    return self.lastIdx, self._array[self.lastIdx]
end

function CircularArray:Destroy()

end

return CircularArray