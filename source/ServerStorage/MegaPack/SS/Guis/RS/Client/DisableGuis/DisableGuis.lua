local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerGui  = player:WaitForChild("PlayerGui")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local DisableGuisSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="DisableGuis"})
local DisableGuisRE = ReplicatedStorage.Remotes.Events:WaitForChild("DisableGuis")

local function handler(command, filterType, guiNameSet)
    if command == "Enable" then
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if not gui:IsA("LayerCollector") then continue end
            if gui.Name == "LoadingScreen" then continue end
            if gui.Name == "TouchGui" then
                gui.TouchControlFrame.Visible = true
            else
                gui.Enabled = true
            end
        end
    elseif command == "Disable" then
        filterType = filterType or "exceptions"
        guiNameSet = guiNameSet or {}
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui.Name == "Cmdr" then continue end
            if filterType == "exceptions" then
                if guiNameSet[gui.Name] then
                    continue
                else
                    if gui.Name == "TouchGui" then
                        gui.TouchControlFrame.Visible = false
                    else
                        gui.Enabled = false
                    end
                end
            elseif filterType == "disableList" then
                if guiNameSet[gui.Name] then
                    if gui.Name == "TouchGui" then
                        gui.TouchControlFrame.Visible = false
                    else
                        gui.Enabled = false
                    end
                end
            end
        end
    end
end

DisableGuisSE:Connect(handler)
DisableGuisRE.OnClientEvent:Connect(handler)

return {}