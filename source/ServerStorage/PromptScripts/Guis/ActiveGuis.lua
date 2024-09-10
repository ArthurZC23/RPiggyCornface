local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

for _, service in ipairs({ReplicatedStorage, ReplicatedFirst, ServerStorage, StarterGui, StarterPack, StarterPlayer, Workspace}) do
    for i, desc in ipairs(service:GetDescendants()) do
        if not desc:IsA("GuiObject") then continue end
        if desc:IsA("ImageButton") or desc:IsA("TextButton") then
            print(desc:GetFullName())
        else
            desc.Active = false
        end
    end
end