-- local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local ReplicatedFirst = game:GetService("ReplicatedFirst")
-- local RunService = game:GetService("RunService")

-- local PreloadAssetsModule = ReplicatedFirst:WaitForChild("PreloadPriorityAssets")
-- local SetCore = require(ReplicatedFirst:WaitForChild("SetCore"))

-- local RootF = script:FindFirstAncestor("Code")
-- local LoadingUtils = require(RootF:WaitForChild("LoadingUtils"))

-- local preloadLock = true
-- local preloadLockTimer = true

-- local localPlayer = Players.LocalPlayer
-- local PlayerGui  = localPlayer:WaitForChild("PlayerGui")

-- local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
-- gui.Parent = PlayerGui

-- ReplicatedFirst:RemoveDefaultLoadingScreen()

-- local root = gui.Root
-- local loadingScreen = root.LoadingScreen
-- local lBar = loadingScreen.LoadingBar.LoadingBar
-- local lText = loadingScreen.LoadingBar.TextLabel
-- local message = loadingScreen.Message

-- local finishedLoading = false

-- local durationsBeforePlayerDataIsReady = {
--     t1 = 6,
--     t2 = 4,
-- }

-- local durationsAfterPlayerDataIsReady = {}
-- for time, timeValue in pairs(durationsBeforePlayerDataIsReady) do
--     durationsAfterPlayerDataIsReady[time] = 0.5 * timeValue
-- end

-- local function findSessionLockingWarning()
--    return ReplicatedStorage:FindFirstChild("DebugEvent")
-- end

-- do
--     task.spawn(function()
--         require(PreloadAssetsModule)
--         preloadLock = false
--     end)

--     task.delay(10, function()
--         preloadLockTimer = false
--         if preloadLock then
--             error("Assets took more than 10 seconds to load.")
--         end
--     end)
-- end

-- -- https://devforum.roblox.com/t/resetbuttoncallback-has-not-been-registered-by-the-corescripts/78470
-- -- They are not guaranteed to be registered within a certain time frame. You should wrap these calls in a pcall and continuously try it at a time interval until it goes through.

-- local function setCoreInit()
--     repeat
--         local ok = pcall(SetCore.setCoreInitLoadingScreen)
--         task.wait(1)
--     until finishedLoading or ok
--     while not finishedLoading do
--         task.wait(1)
--     end
--     repeat
--         local ok = pcall(SetCore.setCoreInitGame)
--         task.wait(1)
--     until ok
-- end
-- task.spawn(setCoreInit)

-- -- if RunService:IsStudio() then
-- --     gui.Enabled = false
-- --     finishedLoading = true
-- --     return
-- -- end

-- local connText
-- connText = lBar:GetPropertyChangedSignal("Size"):Connect(function()
--     lText.Text = ("%d%%"):format(100 * lBar.Size.X.Scale)
-- end)
-- lText.Text = "0%"

-- local sessionLockConn

-- local function cleanup(f1, f2, f3, f4)
--     if not (f1 and f2 and f3 and f4) then return end

--     local character = localPlayer.Character
--     if not character then
--         character = localPlayer.CharacterAdded:Wait()
--     end
--     while character.Parent == nil do
--         character.AncestryChanged:Wait()
--     end

--     connText:Disconnect()
--     connText = nil

--     sessionLockConn:Disconnect()
--     sessionLockConn = nil

--     task.wait(0.5)

--     LoadingUtils.fadeOut(0.5)
--     LoadingUtils.clearLoadingScreen(root)
--     root.BackgroundTransparency = 1
--     LoadingUtils.fadeIn(0.5)
--     finishedLoading = true
-- end

-- local db = false
-- local function thirdPart(prevF1, prevF2)
--     if not (prevF1 and prevF2) then return end
--     -- task.wait() -- Problem A. If I yield in this body of code, the remote doesn't handle the event.
--     print("LoadingScreen 5")
--     while preloadLock and preloadLockTimer do
--         task.wait()
--     end
--     print("LoadingScreen 6")
--     message.Text = "Loading Player Data"
--     do
--         task.wait() -- Problem A This makes the OnClientEvent not work. The time argument doesn't matter
--     end
--     local SessionLockingWarningRE = ReplicatedStorage
--         :WaitForChild("DebugEvent")
--     print("LoadingScreen 7")
--     -- task.wait() -- Problem A
--     sessionLockConn = SessionLockingWarningRE.OnClientEvent:Connect(function(isSessionLocked, delta)
--         print("Received Session Lock Warning Event")
--         if isSessionLocked then
--             print("Session Locked")
--             message.Text = ("Your data didn't finish saving in another server. This could take up to %s minutes."):format(delta)
--         else
--             if db then
--                 task.delay(30, function()
--                     error("LoadingUtils.load(0.2, 1, cleanup) was called more than once")
--                 end)
--             end
--             print("Session Not Locked")
--             db = true
--             LoadingUtils.load(0.2, 1, cleanup)
--         end
--     end)
-- end

-- local function secondPart(prevF1, prevF2, prevF3, prevF4)
--     if not (prevF1 and prevF2 and prevF3 and prevF4) then return end
--     print("LoadingScreen 2")
--     LoadingUtils.waitForGameToLoad(3)
--     print("LoadingScreen 3")
--     message.Text = "Loading Assets"
--     local duration
--     if findSessionLockingWarning() then
--         duration = durationsBeforePlayerDataIsReady.t2
--     else
--         duration = durationsAfterPlayerDataIsReady.t2
--     end
--     print("LoadingScreen 4")
--     print(duration)
--     LoadingUtils.load(duration, 0.8, thirdPart)
-- end

-- local function firstPart()
--     message.Text = "Loading Game"
--     task.wait(1)

--     LoadingUtils.fadeIn(1)

--     local duration
--     if findSessionLockingWarning() then
--         duration = durationsBeforePlayerDataIsReady.t1
--     else
--         duration = durationsAfterPlayerDataIsReady.t1
--     end

--     print("LoadingScreen 1")
--     LoadingUtils.load(duration, 0.5, secondPart)
-- end

-- firstPart()