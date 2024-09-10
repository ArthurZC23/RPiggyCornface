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
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="OddsPage"})
tabPageManager:addGui(TabPage)
local ExitButton = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="ExitButton"})
local DetailsBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="DetailsBtn"})
local RewardProto = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="RewardProto"})
local Container = RewardProto.Parent
RewardProto.Parent = nil

local View = {}
View.__index = View
View.className = "SpinWheel_1OddsView"
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


function View:handleGoToDetails()
    local maid = Maid.new()
    maid:Add2(DetailsBtn.Activated:Connect(function()
        do
            local action = {
                name = "viewTab",
                tabName = "SpinWheel_1Details",
            }
            self.playerState:set(S.LocalSession, "SpinWheelGui", action)
        end
    end))
    return maid
end

function View:createRewardOdds()
    local maid = Maid.new()
    for id, data in pairs(Data.SpinWheel.SpinWheel.idData["1"].rewards) do
        local odds = Data.SpinWheel.SpinWheel.idData["1"].oddsView[id]
        local _gui = maid:Add2(RewardProto:Clone())
        local ImageContainer = _gui.ImageContainer
        local Vpf = ImageContainer.Vpf
        local ImageLabel = ImageContainer.ImageLabel
        if data.isVpf then
            ImageLabel.Visible = false
            AssetsUtils.setModel(Vpf, "MonsterSkin", {
                id = data.assetId,
                cameraProps = data.vpf,
                WorldModel = Vpf.WorldModel
            })
            local Model = Vpf.Model
            Model:PivotTo(CFrame.new(0, 0, 0))
            maid:Add2(Vpf.Model)
        else
            Vpf.Visible = false
            ImageLabel.Image = data.thumbnail
        end
        _gui.RewardName.Text = data.viewName
        _gui.Odds.Text = odds
        _gui.Name = id
        _gui.LayoutOrder = tonumber(id)
        _gui.Visible = true
        _gui.Parent = Container
    end
    return maid
end


function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add2(self:handleGoToWheel())
    maid:Add2(self:handleGoToDetails())
    maid:Add2(self:createRewardOdds())
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