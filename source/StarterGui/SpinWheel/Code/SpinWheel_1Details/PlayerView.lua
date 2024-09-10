local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
local AssetsUtils = Mod:find({"Assets", "Shared", "Utils"})
local ViewUtils = Mod:find({"Gui", "ViewUtils"})

local localPlayer = Players.LocalPlayer
local ClientSherlock = Mod:find({"Sherlocks", "Client"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local tabPageManager = ClientSherlock:find({"PageManager", "SpinWheel"})
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="DetailsPage"})
tabPageManager:addGui(TabPage)
local ExitButton = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="ExitButton"})
local RewardsBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="RewardsBtn"})

local View = {}
View.__index = View
View.className = "SpinWheel_1DetailsView"
View.TAG_NAME = View.className

local function setAttributes()

end
setAttributes()

function View.new(controller)
    local self = {
        _maid = Maid.new(),
        controller = controller,
        playerState = controller.playerState,
    }
    setmetatable(self, View)
    if not self:getFields() then return end

    return self
end

function View:handleGoToWheel()
    local maid = Maid.new()
    maid:Add2(ExitButton.Activated:Connect(function()
        do
            local action = {
                name = "viewTab",
                tabName = "SpinWheel_1",
            }
            self.playerState:set(S.LocalSession, "SpinWheelGui", action)
        end
    end))
    return maid
end

function View:handleGoToRewards()
    local maid = Maid.new()
    maid:Add2(RewardsBtn.Activated:Connect(function()
        do
            local action = {
                name = "viewTab",
                tabName = "SpinWheel_1Odds",
            }
            self.playerState:set(S.LocalSession, "SpinWheelGui", action)
        end
    end))
    return maid
end


function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add2(self:handleGoToWheel())
    maid:Add2(self:handleGoToRewards())
    maid:Add2(ViewUtils.open(self, TabPage, tabPageManager))
end

function View:close()
    ViewUtils.close(self)
end

function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function View:Destroy()
    self._maid:Destroy()
end

return View