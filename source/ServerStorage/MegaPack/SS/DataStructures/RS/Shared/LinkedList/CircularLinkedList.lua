-- Incomplete. There is no add or remove method. I also don't know if the LL traverse works here.

local LinkedList = require(script.Parent.LinkedList)

local CircularLinkedList = setmetatable({}, {__index=LinkedList})
CircularLinkedList.__index = CircularLinkedList

function CircularLinkedList.new(array)
    local self = {}
	setmetatable(self, {__index=CircularLinkedList})
    self.tail = {value = array[#array]}
    self.head = self.tail
    -- Keep the array order
    for i=#array-1,1,-1 do
        self.head = {nextNode = self.head, value = array[i]}
    end
    self.tail.nextNode = self.head
    return self
end

return CircularLinkedList