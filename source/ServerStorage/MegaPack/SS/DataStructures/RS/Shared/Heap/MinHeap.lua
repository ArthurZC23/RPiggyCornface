local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local MinHeap = {}
MinHeap.__index = MinHeap

local function defaultLt(a, b)
    return a < b
end

function MinHeap.new(capacity, ltF)
    local self = {}
	setmetatable(self, MinHeap)
	self._maid = Maid.new()
	self.heap = {}
	self._maid:Add(function()
		self.heap = {}
	end)
    self.ltF = ltF or defaultLt
    self.capacity = capacity or math.huge
    self.heapSize = 0
    return self
end

function MinHeap:parent(i)
    return math.floor(i/2)
end

function MinHeap:left(i)
    return 2 * i
end

function MinHeap:right(i)
    return 2 * i + 1
end

function MinHeap:getMin()
    return self.heap[1]
end

function MinHeap:insertKey(key)
    if self.capacity == self.heapSize then
        warn("Heap overflow. Key was not inserted.")
        return
    end

    self.heapSize = self.heapSize + 1
    local i = self.heapSize
    self.heap[i] = key

    while (i ~= 1 and self.ltF(self.heap[i], self.heap[self:parent(i)])) do
        self.heap[i], self.heap[self:parent(i)] = self.heap[self:parent(i)], self.heap[i]
        i = self:parent(i)
    end
end

function MinHeap:decreaseKey(i, newVal)
    self.heap[i] = newVal
    while (i ~= 1 and self.ltF(self.heap[i], self.heap[self:parent(i)])) do
        self.heap[i], self.heap[self:parent(i)] = self.heap[self:parent(i)], self.heap[i]
        i = self:parent(i)
    end
end

function MinHeap:extractMin()
    if self.heapSize <= 0 then
        return math.huge
    end
    if self.heap_size == 1 then
        self.heapSize = self.heapSize - 1
        return self.heap[1]
    end

    local root = self.heap[1]
    self.heap[1] = self.heap[self.heapSize]
    self.heap[self.heapSize] = nil
    self.heapSize = self.heapSize - 1
    self:MinHeapify(1)
    return root
end

function MinHeap:deleteKey(i)
    self:decreaseKey(i, -math.huge)
    self:extractMin()
end

function MinHeap:MinHeapify(i)
    local leftChild = self:left(i)
    local rightChild = self:right(i)
    local smallest = i
    if (leftChild <= self.heapSize and self.ltF(self.heap[leftChild], self.heap[i])) then
        smallest = leftChild
    end
    if (rightChild <= self.heapSize and self.ltF(self.heap[rightChild], self.heap[smallest])) then
        smallest = rightChild
    end
    if smallest ~= i then
        self.heap[i], self.heap[smallest] = self.heap[smallest], self.heap[i]
        self:MinHeapify(smallest)
    end
end

function MinHeap:Destroy()
	self._maid:Destroy()
end

return MinHeap