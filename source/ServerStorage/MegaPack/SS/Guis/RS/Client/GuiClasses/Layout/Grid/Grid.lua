local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local Grid = {}
Grid.__index = Grid

function Grid.new(guiObj, kwargs)

	local self = {}
	setmetatable(self, {__index = Grid})
	self._maid = Maid.new()

	self.guiObj = guiObj
	self.layout = guiObj:FindFirstChildOfClass("UIGridLayout")

	if not self.layout then
		error(("guiObj %s requires UIGridLayout child"):format(guiObj:GetFullName()), 2)
	end

	self.kwargs = kwargs or {}

	self._maid:Add(
		guiObj:GetPropertyChangedSignal("AbsoluteSize"):Connect(
			function ()
				self:updateCellDimensions()
			end
		)
	)
	self:updateCellDimensions()
	
	if kwargs.scroll then
		if kwargs.scroll.scrollDirection == "Vertical" then
			self._maid:Add(self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
				function () self:updateCanvasSizeVertical() end))
			self:updateCanvasSizeVertical()
		elseif kwargs.scroll.scrollDirection == "Horizontal" then
			self._maid:Add(self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
				function () self:updateCanvasSizeHorizontal() end))
			self:updateCanvasSizeHorizontal()
		else
			error(("Scroll direction %s is not valid."):format(kwargs.scroll.scrollDirection))
		end
	elseif kwargs.expansion then
		if kwargs.expansion.direction == "Vertical" then
			self._maid:Add(self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
				function () self:updateSizeVertical() end))
			self:updateSizeVertical()
		elseif kwargs.expansion.direction == "Horizontal" then
			self._maid:Add(self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
				function () self:updateSizeHorizontal() end))
			self:updateSizeHorizontal()
		elseif kwargs.expansion.direction == "Both" then
			self._maid:Add(self.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
				function () self:updateSize() end))
			self:updateSize()
		else
			error(("Scroll direction %s is not valid."):format(kwargs.scroll.scrollDirection))
		end
	end
	return self
end

function Grid:updateSize()
	self.guiObj.Size = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X  + 0.5 * self.layout.CellSize.X.Offset,
		0,
		self.layout.AbsoluteContentSize.Y + 0.5 * self.layout.CellSize.Y.Offset
	)
end

function Grid:updateSizeVertical()
	self.guiObj.Size = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X,
		0,
		self.layout.AbsoluteContentSize.Y + 0.5 * self.layout.CellSize.Y.Offset
	)
end

function Grid:updateSizeHorizontal()
	self.guiObj.Size = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X  + 0.5 * self.layout.CellSize.X.Offset,
		0,
		self.layout.AbsoluteContentSize.Y
	)
end

function Grid:updateCanvasSizeHorizontal()
	self.guiObj.CanvasSize = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X  + 0.5 * self.layout.CellSize.X.Offset,
		0,
		self.layout.AbsoluteContentSize.Y
	)
end

function Grid:updateCanvasSizeVertical()
	self.guiObj.CanvasSize = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X,
		0,
		self.layout.AbsoluteContentSize.Y + 0.5 * self.layout.CellSize.Y.Offset
	)
end

function Grid:updateCanvasSize()
	self.guiObj.CanvasSize = UDim2.new(
		0,
		self.layout.AbsoluteContentSize.X  + 0.5 * self.layout.CellSize.X.Offset,
		0,
		self.layout.AbsoluteContentSize.Y + 0.5 * self.layout.CellSize.Y.Offset
	)
end


function Grid:updateCellDimensions()
	local cellSize = self.kwargs.CellSize or UDim2.new(0.2, -10, 0.4, -10)
	local cellPadding = self.kwargs.CellPadding or UDim2.new(0, 10, 0, 10)
	local parentSize = self.guiObj.AbsoluteSize

	local xCellTotalOffset = cellSize.X.Scale * parentSize.X + cellSize.X.Offset
	local yCellTotalOffset = cellSize.Y.Scale * parentSize.Y + cellSize.Y.Offset
	self.layout.CellSize = UDim2.new(
		0,
		xCellTotalOffset,
		0,
		yCellTotalOffset
	)

	local xTotalPaddingOffset = cellPadding.X.Scale * parentSize.X + cellPadding.X.Offset
	local yTotalPaddingOffset = cellPadding.Y.Scale * parentSize.Y + cellPadding.Y.Offset
	self.layout.CellPadding = UDim2.new(
		0,
		xTotalPaddingOffset,
		0,
		yTotalPaddingOffset
	)
end

function Grid:Destroy()
	self._maid:Destroy()
end

return Grid