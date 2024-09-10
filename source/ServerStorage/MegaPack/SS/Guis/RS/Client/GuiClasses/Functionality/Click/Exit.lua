--local FunctionalityFolder = script:FindFirstAncestor("Functionality")
local FunctionalityFolder = script.Parent
local Click = require(FunctionalityFolder.Click)

local Exit = {}
Exit.__index = Exit
setmetatable(Exit, {__index = Click})

function Exit.new(button, frame, kwargs)
	kwargs = kwargs or {}
	kwargs.onActivated = kwargs.onActivated or Exit.onActivated
	local self = Click.new(button, kwargs)
	setmetatable(self, Exit)
	self.frame = frame
    return self
end

function Exit:onActivated()
	print(self.frame, " is Close.")
	self.frame.Visible = false
end

function Exit:Destroy()

end

return Exit