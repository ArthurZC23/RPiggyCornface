local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Promise = Mod:find({"Promise", "Promise"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local PageManager = {}
PageManager.__index = PageManager

function PageManager.new(name, kwargs)
	local self = {
        _maid = Maid.new(),
        name = name,
        guis = {},
        exitEffect = kwargs.exitEffect,
        openEffect = kwargs.openEffect,
        guiEnter = kwargs.guiEnter,
        guiLeave = kwargs.guiLeave,
    }
	setmetatable(self, PageManager)

	self.scheduler = JobScheduler.new(function(job) self:processNextPageAction(job) end)
    self:createFolder()
    self:createSignals()

	local function push(_method, schedule, args)
		local numJobs = self.scheduler:getNumJobs()
		if schedule or (numJobs == 0) then
			self.scheduler:pushJob({
				methodName = _method,
				args = args,
			})
		end
	end

	self.open = function(self, gui, schedule) push("_open", schedule, {gui}) end
	self.close = function(self, gui, schedule) push("_close", schedule, {}) end

	self.currentGui = nil

	return self
end

function PageManager:createFolder()
    self.signalFolder = self._maid:Add(GaiaShared.create("Folder", {
        Name = ("PageManager_%s"):format(self.name),
        Parent = ReplicatedStorage.Bindables,
    }))
end

function PageManager:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.signalFolder, {
        events = {"OpenPage", "ClosePage", "SwitchPage"},
    }))
end

function PageManager:processNextPageAction(job)
	self[job.methodName](self, unpack(job.args))
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
            self.SwitchPageSE:Fire({
                previousGui = self.currentGui,
                newGui = gui,
            })
		else
			self.openEffect()
		end
	end)
	local prom2 = Promise.try(function()
		self.guiEnter(gui)
        self.OpenPageSE:Fire()
	end)
	local ok, err = Promise.all({prom1, prom2}):await()
    if not ok then warn(tostring(err)) end
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
	local ok, err = Promise.all({prom1, prom2}):await()
    if not ok then warn(tostring(err)) end
    self.ClosePageSE:Fire(self.currentGui)
	self.currentGui = nil
end

function PageManager:Destroy()
	self._maid:Destroy()
end

return PageManager