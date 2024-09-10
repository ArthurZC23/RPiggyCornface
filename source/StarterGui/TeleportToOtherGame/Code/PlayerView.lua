local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})
local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})

local View = {}
View.__index = View
View.className = "TeleportToOtherGameView"
View.TAG_NAME = View.className

function View.new(controller)
    local self = {
        _maid = Maid.new(),
        controller = controller,
    }
    setmetatable(self, View)

    return self
end

local ViewUtils = Mod:find({"Gui", "ViewUtils"})
function View:open(kwargs)
    local maid = self._maid:Add2(Maid.new(), "Open")
    task.defer(function()
        maid:Add(self.controller:handleButtons(kwargs))
    end)
    maid:Add(ViewUtils.open(self, GuiFrame, pageManager))
end

function View:close()
    ViewUtils.close(self)
end

function View:Destroy()
    self._maid:Destroy()
end

return View