local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local BigNotificationGuiRE = ReplicatedStorage.Remotes.Events:WaitForChild("BigNotificationGui")
local BigNotificationSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="BigNotificationGui"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local bigNotificationFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BigNotificationFrame"})

local function onNotification(notification, duration)
    duration = duration or 5
    local textLabel = bigNotificationFrame.TextLabel
    bigNotificationFrame.Visible = true
    textLabel.Text = notification
    Promise.delay(duration)
        :andThen(function ()
            if textLabel.Text == notification then
                textLabel.Text = ""
                bigNotificationFrame.Visible = false
            end
        end)
end
BigNotificationGuiRE.OnClientEvent:Connect(onNotification)
BigNotificationSE:Connect(onNotification)