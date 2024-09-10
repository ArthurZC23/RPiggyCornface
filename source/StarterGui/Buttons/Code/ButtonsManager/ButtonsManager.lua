local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local LocalData = Mod:find({"Data", "LocalData"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local ButtonsManagerData = LocalData.ButtonsManager.ButtonsManager
local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Maid = Mod:find({"Maid"})

local guisData = ButtonsManagerData.guisData

local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local Bindables = ReplicatedStorage.Bindables

local localPlayer = Players.LocalPlayer
local PlayerGui  = localPlayer:WaitForChild("PlayerGui")

local function setPageManager()
    for guiKey, data in pairs(guisData) do
        local rootFrame = data.open.openFrame or "GuiFrame"
        local frame = SharedSherlock:find({"EzRef", "Get"}, {inst=PlayerGui:WaitForChild(data.open.guiName), refName=rootFrame})
        pageManager:addGui(frame)
    end
end
setPageManager()

local function open(ctrl, guiKey, schedule, kwargs)
    kwargs = kwargs or {}
    local guiData = guisData[guiKey]
    local view
    local guiName = guiData.name
    -- error("Error in GA open")
    if guiData.guiType == "Player" then
        view = ctrl.playerGuis.controllers[guiName].view
    elseif guiData.guiType == "Char" then
        view = ctrl.charGuis.controllers[guiName].view
    end
    view:open(kwargs)
end

local function handleOpenButtons(ctrl)
    local maid = Maid.new()
    for guiKey, data in pairs(guisData) do
        local openData = data.open
        if not openData.btnName then continue end

        local buttonFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=PlayerGui:WaitForChild("Buttons"), refName=openData.btnName})
        local btn = buttonFrame:FindFirstChildWhichIsA("GuiButton")
        local kwargs = openData.kwargs or {}
        maid:Add2(btn.Activated:Connect(function() open(ctrl, guiKey, false, kwargs) end))
        if openData.uxKwargs then maid:Add2(ButtonsUx.addUx(btn, openData.uxKwargs)) end

        -- if Platforms.getPlatform() == Platforms.Console then
        --     local consoleData = openData.console
        --     if not consoleData then continue end
        --     buttonFrame.Visible = not consoleData.hideOpenBtn
        --     local xboxData = consoleData.gamepads.xbox
        --     if not xboxData then continue end
        --     ContextActionService:BindAction(
        --         guiKey,
        --         function()
        --             Bach:play("Click", Bach.SoundTypes.SfxGui)
        --             local openBtnLikeEvent = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal=openData.eventLikeBtn})
        --             openBtnLikeEvent:Fire(true)
        --         end,
        --         false,
        --         xboxData.keyCode
        --     )
        --     local consoleBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=PlayerGui:WaitForChild("Buttons"), refName=xboxData.name})
        --     consoleBtn.Visible = true
        -- end

    end
    return maid
end

local function handleOpenEventLikeBtn(ctrl)
    local maid = Maid.new()
    for guiKey, data in pairs(guisData) do
        local openData = data.open
        if not openData.eventLikeBtn then continue end
        GaiaShared.createBindables(ReplicatedStorage, {
            events = {openData.eventLikeBtn}
        })
        maid:Add2(Bindables.Events[openData.eventLikeBtn])
        local signalE = maid:Add2(SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal=openData.eventLikeBtn}))
        maid:Add2(signalE:Connect(function(schedule, kwargs)
            open(ctrl, guiKey, schedule, kwargs)
        end))
    end
    return maid
end

local function close(ctrl, guiKey, schedule, kwargs)
    local guiData = guisData[guiKey]
    local view
    local guiName = guiData.name
    -- error("Error in GA close")
    if guiData.guiType == "Player" then
        view = ctrl.playerGuis.controllers[guiName].view
    elseif guiData.guiType == "Char" then
        view = ctrl.charGuis.controllers[guiName].view
    end
    view:close(kwargs)
end

local UserInputService = game:GetService("UserInputService")
local function handleCloseButtons(ctrl)
    local maid = Maid.new()
    local consoleConns = {}
    local function handleConsoleGuiExit(btn, guiKey)
        local function update(isBtnVisible)
            if isBtnVisible then
                consoleConns[guiKey] = UserInputService.InputBegan:Connect(function(input)
                    if (input.KeyCode == Enum.KeyCode.ButtonB) then
                        close(ctrl, guiKey, false)
                    end
                end)
            else
                if consoleConns[guiKey] then
                    consoleConns[guiKey]:Disconnect()
                    consoleConns[guiKey] = nil
                end
            end
        end
        btn:GetPropertyChangedSignal("Visible"):Connect(function()
            update(btn.Visible)
        end)
        update(btn.Visible)
        btn.Selectable = false
        btn.TextLabel.Text = "B"
    end
    for guiKey, data in pairs(guisData) do
        local closeData = data.close
        if not closeData.hasExitBtn then continue end
        local exitBtn = closeData.exitButton or "ExitButton"
        local buttonFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=PlayerGui:WaitForChild(data.open.guiName), refName=exitBtn})
        local btn = buttonFrame:FindFirstChildWhichIsA("GuiButton")
        if Platforms.getPlatform() == Platforms.Platforms.Console then
            task.spawn(function()
                handleConsoleGuiExit(btn, guiKey)
            end)
        end
        local kwargs = closeData.kwargs or {}
        maid:Add2(btn.Activated:Connect(function() close(ctrl, guiKey, false, kwargs) end))
        maid:Add2(ButtonsUx.addUx(btn, {
            dilatation = {
                expandFactor = {
                    X=1.1,
                    Y=1.1,
                }
            }
        }))
    end
    return maid
end

local function handleCloseEventLikeBtn(ctrl)
    local maid = Maid.new()
    for guiKey, data in pairs(guisData) do
        if not data.close.eventLikeBtn then continue end
        GaiaShared.createBindables(ReplicatedStorage, {
            events = {data.close.eventLikeBtn}
        })
        maid:Add2(Bindables.Events[data.close.eventLikeBtn])
        local signalE = maid:Add2(SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal=data.close.eventLikeBtn}))
        maid:Add2(signalE:Connect(function(schedule, kwargs)
            close(ctrl, guiKey, schedule, kwargs)
        end))
    end
    return maid
end

local module = {}

function module.handleOpen(ctrl)
    local maid = Maid.new()
    maid:Add2(handleOpenButtons(ctrl))
    maid:Add2(handleOpenEventLikeBtn(ctrl))
    return maid
end

function module.handleClose(ctrl)
    local maid = Maid.new()
    maid:Add2(handleCloseButtons(ctrl))
    maid:Add2(handleCloseEventLikeBtn(ctrl))
    return maid
end

return module

-- local Bindables = ReplicatedStorage.Bindables

-- local function handleGamepadShortcuts()
--     for _, gui in ipairs(CollectionService:GetTagged("GamepadButtonsShortcuts")) do
--         if Platforms.getPlatform() == Platforms.Platforms.Console then
--             local btn = gui.Btn
--             btn.Activated:Connect(function()
--                 local signalName = ""
--                 local signal = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="ActivateShopTab"})
--             end)
--             gui.Visible = true
--         else
--             gui.Visible = false
--         end
--         gui.Visible = true
--     end
-- end
-- handleGamepadShortcuts()
