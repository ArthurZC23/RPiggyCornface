local RootFolder = script:FindFirstAncestor("ScrollingFrame")
local BaseClass = require(RootFolder.AbstractScrollingFrame.AbstractScrollingFrame)

local ScrollingFrameListLayout = setmetatable({}, {__index = BaseClass})


function ScrollingFrameListLayout.new(scrollingFrame, itemScale, itemPadding)

    local self = {}
    setmetatable(self, {__index = ScrollingFrameListLayout})

    self.scrollingFrame = scrollingFrame
    self.layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
    self.itemScale = itemScale
    self.itemPadding = itemPadding

    if not self.layout then
        error("ScrollingFrameListLayout requires ScrollingFrame with UIListLayout", 2)
    end

    scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(
        function ()
            self:updateListScale()
        end
    )
	self:updateListScale()

	self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
        function ()
            --print("Canvas 1")
            self:updateCanvasSize()
            --print("Canvas 7")
        end
	)
	self:updateCanvasSize()

    return self
end

function ScrollingFrameListLayout:updateCanvasSize()
    --print("Canvas 2")
	if self.layout.FillDirection == Enum.FillDirection.Vertical then
		self.scrollingFrame.CanvasSize = UDim2.new(
			1,
			0,
			0,
			self.layout.AbsoluteContentSize.Y
				+ self.layout.Padding.Offset
				+ self.layout.Padding.Scale
				* self.layout.Parent.AbsoluteSize.Y
		)
	else
		self.scrollingFrame.CanvasSize = UDim2.new(
			0,
			self.layout.AbsoluteContentSize.X
				+ self.layout.Padding.Offset
				+ self.layout.Padding.Scale
				* self.layout.Parent.AbsoluteSize.X,
			1,
			0
		)
	end
    --print("Canvas 3")
	self:updateListScale()
    --print("Canvas 6")
end

function ScrollingFrameListLayout:updateListScale()
    --print("Canvas 4")
    local parentSize = self.scrollingFrame.AbsoluteSize
	local xItemSize = (self.itemScale.X.Scale * parentSize.X + self.itemScale.X.Offset)
	local yItemSize = (self.itemScale.Y.Scale * parentSize.Y + self.itemScale.Y.Offset)
    for _, child in ipairs(self.scrollingFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Size = UDim2.new(0, xItemSize, 0, yItemSize)
        end
    end

    if self.layout.FillDirection == Enum.FillDirection.Vertical then
        self.layout.Padding = UDim.new(0, self.itemPadding * parentSize.Y)
    else
		self.layout.Padding = UDim.new(0, self.itemPadding * parentSize.X)
    end
    --print("Canvas 5")
end

function ScrollingFrameListLayout:Destroy()
end

return ScrollingFrameListLayout