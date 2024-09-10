local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local Tab1Proto = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Tab1Proto"})
local Tabs1Container = Tab1Proto.Parent
Tab1Proto.Parent = nil

local View = {}
View.__index = View
View.className = "ShopTabView"
View.TAG_NAME = View.className

function View.new(controller)
    local self = {
        controller = controller,
        _maid = Maid.new(),
    }
    setmetatable(self, View)

    return self
end

function View:createTab(data)
    local maid = Maid.new()

    local _gui = maid:Add(Tab1Proto:Clone())
    _gui.Name = data.name
    local TabName = _gui.Btn.TabName
    TabName.Text = data.prettyName
    maid:Add(self.controller:handleTab(_gui, data))
    _gui.LayoutOrder = data.LayoutOrder
    _gui.Visible = true
    _gui.Parent = Tabs1Container

    return maid
end

local ClientSherlock = Mod:find({"Sherlocks", "Client"})
function View:handlePageManager()
    local maid = Maid.new()
    local function update(state)
        local tab = state.viewTab
        local tabData = Data.Shop.ShopTabs.nameData[tab]
        local view = self.controller.playerGuis.controllers[tabData.guiName].view
        maid:Add2(function()
            view:close()
        end, "CloseTab")
        view:open()
    end
    maid:Add(self.controller.playerState:getEvent(S.LocalSession, "ShopGui", "viewTab"):Connect(update))

    return maid
end

function View:initTabs()
    local maid = Maid.new()
    local tabsData = Data.Shop.ShopTabs.idData
    for id, data in pairs(tabsData) do
        maid:Add(self:createTab(data))
    end
    maid:Add(self:handlePageManager())
    return maid
end

local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="GuiFrame"})
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})
local ViewUtils = Mod:find({"Gui", "ViewUtils"})
function View:open(kwargs)
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add(function()
        do
            local action = {
                name = "reset",
            }
            self.controller.playerState:set(S.LocalSession, "ShopGui", action)
        end
    end)
    maid:Add(self:initTabs())
    do
        local action = {
            name = "viewTab",
            tabName = kwargs.tabName,
        }
        self.controller.playerState:set(S.LocalSession, "ShopGui", action)
    end
    maid:Add2(ViewUtils.open(self, GuiFrame, pageManager))
end

function View:close()
    ViewUtils.close(self)
end

function View:Destroy()
    self._maid:Destroy()
end

return View