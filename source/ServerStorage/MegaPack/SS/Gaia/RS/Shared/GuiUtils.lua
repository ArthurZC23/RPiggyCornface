local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.setZIndex(gui, ZIndex)
    gui.ZIndex = ZIndex
    for _, desc in ipairs(gui:GetDescendants()) do
        if not desc:IsA("GuiObject") then continue end
        desc.ZIndex = ZIndex
    end
end

return module