local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local ViewUtils = Mod:find({"Gui", "ViewUtils"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})

local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})
pageManager:addGui(GuiFrame)

local View = {}
View.__index = View
View.className = "SpinWheelGuiManagerView"
View.TAG_NAME = View.className

function View.new(controller)
    local self = {
        controller = controller,
        _maid = Maid.new(),
    }
    setmetatable(self, View)

    return self
end

function View:open(kwargs)
    local maid = self._maid:Add2(Maid.new(), "Open")

    maid:Add(ViewUtils.handlePageManager({
        controllers = self.controller.playerGuis.controllers,
        stateManager = self.controller.playerState,
        scope = "SpinWheelGui",
        tabsData = Data.SpinWheel.SpinWheel.idData["1"].gui.tabs,
        openTabName = kwargs.tabName
    }))

    maid:Add2(ViewUtils.open(self, GuiFrame, pageManager))
end

function View:close()
    ViewUtils.close(self)
end

function View:Destroy()
    self._maid:Destroy()
end

return View