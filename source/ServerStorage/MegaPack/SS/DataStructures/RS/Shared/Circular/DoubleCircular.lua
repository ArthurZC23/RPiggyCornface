-- Incomplete

local Circular = {}
Circular.__index = Circular

function Circular.new(tbl)
	local self = {}
	setmetatable(self, Circular)
	local idx = 1
	for k, v in pairs(tbl) do
		if typeof(v) == "table" then
			assert(
				v._next == nil,
				("Table %s must not containt key _next for Circular to work."):format(tostring(v))
			)
		end
	end

	return self
end

function Circular:Destroy()

end

return Circular