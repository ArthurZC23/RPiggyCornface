local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local module = {}

function module.setCoreInitLoadingScreen()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	StarterGui:SetCore("ResetButtonCallback", false)
	StarterGui:SetCore("ChatBarDisabled", false)
    -- local function openEmoteMenu(actionName, inputState, inputObject)
    --     if inputState == Enum.UserInputState.Begin then
    --         local isEmoteMenuOpen = GuiService:GetEmotesMenuOpen()
    --         GuiService:SetEmotesMenuOpen(not isEmoteMenuOpen)
    --     end
    -- end
    -- ContextActionService:BindAction("OpenEmoteMenu", openEmoteMenu, false, Enum.KeyCode.B)
end

-- This could be outside RF and be refactored to Data
function module.setCoreInitGame()
    -- Need to set again because corescript could not be loaded properly during loading screen
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	StarterGui:SetCore("ResetButtonCallback", true)
	StarterGui:SetCore("ChatBarDisabled", false)
end

return module