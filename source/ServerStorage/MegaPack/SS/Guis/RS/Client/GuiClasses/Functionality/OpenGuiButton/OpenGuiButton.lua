local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local RootFolder = script:FindFirstAncestor("GuiClasses")
local MainGuiUtils = require(RootFolder.MainGui.MainGuiUtils)

local OpenGuiButton = {}
OpenGuiButton.__index = OpenGuiButton

function OpenGuiButton.new(openButton, targetGuiObj, kwargs)
    local self = {}
    setmetatable(self, OpenGuiButton)
    self._maid = Maid.new()
    self.openButton = openButton
    self.targetGuiObj = targetGuiObj
    self.kwargs = kwargs
    local hof = kwargs.hof or function (func)
        return func
    end
    if kwargs.onActivated then
        self.onActivated = kwargs.onActivated
    else
        self.onActivated = self.activations[kwargs.activationType or "Standard"]
    end

    self._maid:Add(openButton.Activated:Connect(
        hof(
            function (...)
                self:onActivated(...)
            end)
        )
    )
    return self
end

function OpenGuiButton:onMainGuiActivated()
    local mainGui = MainGuiUtils.getMainGuiObj()
    mainGui.Value = self.targetGuiObj 
end

function OpenGuiButton:onStandardActivated()
    self.targetGuiObj.Visible = true
end

function OpenGuiButton:onUniqueGuiActivated()
    self.kwargs.uniqueGui.Value = self.targetGuiObj
end

OpenGuiButton.activations = {
    Standard = OpenGuiButton.onStandardActivated,
    MainGui = OpenGuiButton.onMainGuiActivated,
    UniqueGui = OpenGuiButton.onUniqueGuiActivated,
}

function OpenGuiButton:Destroy()
    self._maid:Destroy()
end

return OpenGuiButton