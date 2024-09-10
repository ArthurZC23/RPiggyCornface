local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})

local PageManager = {}
PageManager.__index = PageManager

function PageManager.new(name, kwargs)
	local self = {}
	setmetatable(self, PageManager)
	self.name = name
	self._maid = Maid.new()
	self.guis = {}

	self.exitEffect = kwargs.exitEffect
	self.openEffect = kwargs.openEffect
	self.guiEnter = kwargs.guiEnter
	self.guiLeave = kwargs.guiLeave
	
	self.db = false
	self.open = function(self, gui)
		if self.db then return end
		self.db = true
		self:_open(gui)
		self.db = false
	end
	self.close = function(self)
		if self.db then return end
		self.db = true
		self:_close()
		self.db = false
	end

	self.currentGui = nil

	return self
end

function PageManager:addGui(gui, kwargs)
	kwargs = kwargs or {}
	assert(
		not(gui.Visible and self.currentGui),
		("PageManager %s added visible gui while gui was already visible."):format(self.name)
	)

	if gui.Visible then self.currentGui = gui end
	self.guis[gui] = kwargs
end

function PageManager:_open(gui)
	if not self.guis[gui] then
		warn(("PageManager %s doesn't manage Gui %s"):format(self.name, gui:GetFullName()))
		return
	end
	if self.currentGui == gui then return end
	local prom1 = Promise.try(function()
		if self.currentGui then
			local guiLeave = self.guis[gui].guiLeave or self.guiLeave
			guiLeave(self.currentGui)
		else
			self.openEffect()
		end
	end)
	local prom2 = Promise.try(function()
		self.guiEnter(gui)
	end)
	Promise.all({prom1, prom2}):await()
	
	self.currentGui = gui
end

function PageManager:_close()
	if self.currentGui == nil then return end
	local prom1 = Promise.try(function()
		self.guiLeave(self.currentGui)
	end)
	local prom2 = Promise.try(function()
		self.exitEffect()
	end)
	Promise.all({prom1, prom2}):await()
	self.currentGui = nil
end

function PageManager:Destroy()
	self._maid:Destroy()
end

return PageManager