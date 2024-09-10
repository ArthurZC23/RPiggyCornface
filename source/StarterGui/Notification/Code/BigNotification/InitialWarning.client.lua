local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local bigNotificationFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="BigNotificationFrame"})

local function run()
    local duration = 40
    local textLabel = bigNotificationFrame.TextLabel
    bigNotificationFrame.Visible = true
    local message = "We are ADDING a x1K coin WORLD BOOST for you to get back to being OP fast. Shampoo progression was REMADE to allow for more shampoos to be in the game. You still have the same shampoo as before "
        .."but shampoos cost less GOLD and give less hair (hair capacity and jump were adjusted proportionally)."
    textLabel.Text = message

    Promise.delay(duration)
        :andThen(function ()
            if textLabel.Text == message then
                textLabel.Text = ""
                bigNotificationFrame.Visible = false
            end
        end)
end
--run()