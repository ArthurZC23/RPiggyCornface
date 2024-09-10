local FunctionalityFolder = script.Parent
local Click = require(FunctionalityFolder.Click)

local Open = {}
Open.__index = Open
setmetatable(Open, {__index = Click})

function Open.new(button, frame, kwargs)
	kwargs = kwargs or {}
	kwargs.onActivated = kwargs.onActivated or Open.onActivated
	local self = Click.new(button, kwargs)
	setmetatable(self, Open)
	self.frame = frame
    return self
end

function Open:onActivated()
	print(self.frame, " is Visible.")
	self.frame.Visible = true
end

function Open:Destroy()

end

return Open