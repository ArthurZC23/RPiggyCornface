local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local BigBen = Mod:find({"Cronos", "BigBen"})


local GuiRotation = {}
GuiRotation.__index = GuiRotation
GuiRotation.className = "GuiRotation"
GuiRotation.TAG_NAME = GuiRotation.className

function GuiRotation.new(gui)

    local self = {
        gui = gui,
        _maid = Maid.new(),
    }
    setmetatable(self, GuiRotation)

    self._maid:Add(BigBen.every(function() return gui:GetAttribute("GuiRotationFrameStep") or 1 end, "Heartbeat", "frame", true):Connect(function()
        --print("Rotate")
        gui.Rotation += gui:GetAttribute("RotationStep")
    end))

    return self
end

function GuiRotation:Destroy()
    self._maid:Destroy()
end

return GuiRotation