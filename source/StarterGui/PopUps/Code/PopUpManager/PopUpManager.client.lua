local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

-- local ShowPopUpSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="ShowPopUp"})

-- local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
-- local popups = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="PopUps"})

-- ShowPopUpSE:Connect(function(popupName)
--     for _, fr in ipairs(popups:GetChildren()) do
--         if fr:IsA("Frame") then fr.Visible = false end
--     end
--     popups[popupName].Visible = true
-- end)