local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local MinHeap = Mod:find({"DataStructures", "Heap", "MinHeap"})

local PQ = {}
PQ.__index = PQ

local function heapLt(a, b)
    if a == nil or b == nil then
        task.defer(function()
            error(("Error in PQ Min HEAP.\na = %s\nb = %s"):format(tostring(a), tostring(b)))
        end)
    end
    return a[2] < b[2]
end

function PQ.new(capacity)
    local self = {}
	setmetatable(self, PQ)
	self._maid = Maid.new()
	capacity = capacity or math.huge
	self.heap = self._maid:Add(MinHeap.new(capacity, heapLt))
    return self
end

function PQ:push(item, priority)
    local entry = {item, priority}
    self.heap:insertKey(entry)
end

function PQ:pop()
    local entry = self:getHighestPriority()
    local item, priority = entry[1], entry[2]
    self:deleteHighestPriority()
    return item, priority
end

function PQ:getHighestPriority()
    return self.heap:getMin()
end

function PQ:deleteHighestPriority()
    self.heap:deleteKey(1)
end

function PQ:getSize()
	return self.heap.heapSize
end

function PQ:Destroy()
	self._maid:Destroy()
end

return PQ