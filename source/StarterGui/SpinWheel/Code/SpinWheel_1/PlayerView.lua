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
local TabPage = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="WheelPage"})
tabPageManager:addGui(TabPage)

local ShowDetailsBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="ShowDetailsBtn"})
local ExitButton = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="ExitButton"})
local WheelOptions = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="WheelOptions"})
local SpinButtonCenter = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="SpinButtonCenter"})
local WheelOptionProto = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="WheelOptionProto"})
WheelOptionProto.Parent = nil
local SpinCounter = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="SpinCounter"})
local RefreshTimer = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="RefreshTimer"})
local BuyPack1Btn = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="BuyPack1Btn"})
local BuyPack2Btn = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="BuyPack2Btn"})
local BuyPack3Btn = SharedSherlock:find({"EzRef", "Get"}, {inst=TabPage, refName="BuyPack3Btn"})

local View = {}
View.__index = View
View.className = "SpinWheel_1View"
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

function View:handleExit()
    local maid = Maid.new()

    maid:Add2(ExitButton.Activated:Connect(function()
        self.playerGuis.controllers["SpinWheelGuiManagerController"].view:close()
        self:close()
    end))

    return maid
end

function View:handleWheelSpin()
    local maid = Maid.new()

    maid:Add2(function()
        WheelOptions:RemoveTag("GuiRotation")
    end)
    WheelOptions:SetAttribute("GuiRotationFrameStep", 2)
    WheelOptions:SetAttribute("RotationStep", 0.2)
    WheelOptions:AddTag("GuiRotation")

    return maid
end

function View:handleShowDetails()
    local maid = Maid.new()
    maid:Add2(ShowDetailsBtn.Activated:Connect(function()
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

function View:createWheelGui()
    local maid = Maid.new()

    for rewardId, data in pairs(Data.SpinWheel.SpinWheel.idData["1"].rewards) do
        local WheelOption = maid:Add2(WheelOptionProto:Clone())
        WheelOption.Rotation = -self:getRewardAngle(rewardId)
        local Segment = WheelOption.Segment
        local Vpf = Segment.Vpf
        local ImageLabel = Segment.ImageLabel
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
            Vpf.TextLabel.Text = data.viewName or ""
        else
            Vpf.Visible = false
            ImageLabel.Image = data.thumbnail
            ImageLabel.TextLabel.Text = data.viewName or ""
        end
        WheelOption.Name = rewardId
        WheelOption.Visible = true
        WheelOption.Parent = WheelOptions
    end

    return maid
end

local Bach = Mod:find({"Bach", "Bach"})
-- function View:showPrize()
--     local maid = Maid.new()
--     local rewardFrame = GuiFrame.Reward
--     local RewardsContainer = rewardFrame.Rewards
--     maid:Add(function()
--         rewardFrame.Visible = false
--     end)
--     local layout = script:GetAttribute("prizeBasePos") + (script:GetAttribute("repetitions") - 1) * script:GetAttribute("diffItems")
--     for _, Container in ipairs(containers) do
--         local assetGui = maid:Add(Container[layout]:Clone())
--         assetGui.ZIndex = 2
--         for _, desc in ipairs(assetGui:GetDescendants()) do
--             if not desc:IsA("GuiObject") then continue end
--             desc.ZIndex = 2
--         end
--         assetGui.Btn.ImageTransparency = 1
--         assetGui.Size = UDim2.fromScale(0.31, 1)
--         maid:Add(self:bgHalo(assetGui))
--         assetGui.Parent = RewardsContainer
--     end
--     rewardFrame.Visible = true
--     Bach:play("ClaimItem", Bach.SoundTypes["SfxGui"])

--     local btn = rewardFrame.ClaimBtnFrame.Btn
--     local finished = maid:Add(SignalE.new())
--     maid:Add(btn.Activated:Connect(function()
--         finished:Fire()
--     end))

--     local timeout = 12
--     if RunService:IsStudio() then
--         timeout = 1e3
--     end

--     local promise = maid:Add2(Promise.fromEvent(finished):timeout(timeout))

--     return maid, promise
-- end

function View:getRewardAngle(rewardId)
    local rewardIdx = tonumber(rewardId)
    local rewardAngle = (rewardIdx - 1) * 45
    return rewardAngle
end

local TweenService = game:GetService("TweenService")
function View:spinToPrize(rewardId)
    local duration = 6
    if RunService:IsStudio() then
        duration = 2
    end
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
    local angle0 = WheelOptions.Rotation
    local theta = math.ceil(angle0 / 360) * 360
    local rotations = Random.new():NextInteger(5, 8) * 360
    local goal = {Rotation = theta + rotations + self:getRewardAngle(rewardId)}
    local tween = TweenService:Create(WheelOptions, tweenInfo, goal)
    tween:Play()

    return Promise.fromEvent(tween.Completed)
end


function View:handleSpinRewardUx()
    local maid = Maid.new()
    maid:Add2(self.SpinWheelUxRE.OnClientEvent:Connect(function(rewardId)
        local _maid = maid:Add2(Maid.new(), "SpinWheelUx")

        _maid:Add2(function()
            self.SpinWheelUxRE:FireServer()
            WheelOptions:AddTag("GuiRotation")
        end)
        WheelOptions:RemoveTag("GuiRotation")

        _maid:Add2(self:spinToPrize(rewardId))
        :andThen(function()
            Bach:play("ChaChing", Bach.SoundTypes.SfxGui)
            task.wait(4)
            -- local methodMaid, promise = self:showPrize()
            -- _maid:Add2(methodMaid)
            -- return promise
        end)
        :timeout(15)
        :catchAndPrint()
        :finally(function()
            maid:Remove("SpinWheelUx")
        end)


    end))
    return maid
end

function View:handleButtonsEvents()
    local maid = Maid.new()

    maid:Add2(self.controller:handleSpinRequest(SpinButtonCenter))

    return maid
end

function View:handleSpinCount()
    local maid = Maid.new()

    local function update(state, action)
        if action.id ~= "1" then return end
        SpinCounter.Text = ("Spins: %s"):format(state.st["1"].spins)
    end
    maid:Add(self.playerState:getEvent(S.Stores, "SpinWheels", "changeSpinCount"):Connect(update))
    local state = self.playerState:get(S.Stores, "SpinWheels")
    update(state, {id = "1"})

    return maid
end

local TimeFormatter = Mod:find({"Formatters", "TimeFormatter"})
local Cronos = Mod:find({"Cronos", "Cronos"})
function View:handleTimer()
    local maid = Maid.new()

    local function stopTimer(state, action)
        if action.id ~= "1" then return end
        maid:Remove("Timer")
    end
    local function startTimer(state, action)
        if action.id ~= "1" then return end
        local t1 = state.st["1"].t1
        local timeLeft = t1 - Cronos:getTime()
        local _maid = maid:Add2(Maid.new(), "Timer")
        _maid:Add2(function()
            RefreshTimer.Text = "Free spin in: 00:00:00"
            RefreshTimer.Visible = false
        end)
        RefreshTimer.Visible = true
        RefreshTimer.Text = ("Free spin in: %s"):format(TimeFormatter.formatToHHMMSS(math.max(timeLeft, 0)))
        _maid:Add2(Promise.try(function()
            while timeLeft > 0 do
                Cronos.wait(1)
                timeLeft = math.max(t1 - Cronos:getTime(), 0)
                RefreshTimer.Text = TimeFormatter.formatToHHMMSS(math.max(timeLeft, 0))
            end
        end))

    end
    maid:Add(self.playerState:getEvent(S.Stores, "SpinWheels", "stopTimer"):Connect(stopTimer))
    maid:Add(self.playerState:getEvent(S.Stores, "SpinWheels", "startSpinTimer"):Connect(startTimer))
    local state = self.playerState:get(S.Stores, "SpinWheels")
    if state.st["1"].t1 then
        startTimer(state, {id = "1"})
    end

    return maid
end

function View:handlePurchaseSpinButtons()
    local maid = Maid.new()

    BuyPack1Btn:SetAttribute("devProduct", "1894713107")
    BuyPack2Btn:SetAttribute("devProduct", "1894713320")
    BuyPack3Btn:SetAttribute("devProduct", "1894713458")

    maid:Add2(function()
        for _, Btn in ipairs({BuyPack1Btn, BuyPack2Btn, BuyPack3Btn}) do
            Btn:RemoveTag("DeveloperProductButton")
        end
    end)
    for _, Btn in ipairs({BuyPack1Btn, BuyPack2Btn, BuyPack3Btn}) do
        Btn:AddTag("DeveloperProductButton")
    end

    return maid
end

function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add2(self:handleExit())
    maid:Add2(self:createWheelGui())
    maid:Add2(self:handleWheelSpin())
    maid:Add2(self:handleShowDetails())
    maid:Add2(self:handleSpinRewardUx())
    maid:Add2(self:handlePurchaseSpinButtons())
    maid:Add2(self:handleButtonsEvents())
    maid:Add2(self:handleSpinCount())
    maid:Add2(self:handleTimer())
    maid:Add2(ViewUtils.open(self, TabPage, tabPageManager))
end

function View:close()
    ViewUtils.close(self)
end

local BinderUtils = Mod:find({"Binder", "Utils"})
function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()

            local bindersData = {
                {"PlayerGuis", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            local remotes = {
                "SpinWheelUx"
            }
            local root = localPlayer
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end

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