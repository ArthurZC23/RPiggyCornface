local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local player = Players.LocalPlayer
local Bindables = ReplicatedStorage.Bindables
local Events = Bindables.Events
local ClientViewPortSizeChange = Events:WaitForChild("ClientViewPortSizeChange")

local AbstractFrameGrid = {}
AbstractFrameGrid.__index = AbstractFrameGrid

function AbstractFrameGrid.new(scrollingFrame)

    assert(
        scrollingFrame.ClassName == "ScrollingFrame",
        ("AbstractFrameGrid requires ScrollingFrame obj."
        .."Received %s instead."):format(scrollingFrame.ClassName)
    )

    local self = {}
    setmetatable(self, AbstractFrameGrid)

    self.scrollingFrame = scrollingFrame

    ClientViewPortSizeChange.Event:Connect(
        function ()
            self:updateCanvasSize()
        end
    )

    return self
end

-- Update canvas to fit all items
function AbstractFrameGrid:updateCanvasSize()

    self.scrollingFrame.CanvasSize = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X 
		,
        0,
		self.layout.AbsoluteContentSize.Y
	)
end

function AbstractFrameGrid:Destroy()

end

return AbstractFrameGrid