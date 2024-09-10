local ShowOneGuiManager = {}
ShowOneGuiManager.__index = ShowOneGuiManager

function ShowOneGuiManager.new(guiReference, kwargs)
    local self = {}
    setmetatable(self, ShowOneGuiManager)
    self.currentGui = guiReference.Value
    self.beforeChange = kwargs.beforeChange or function () end
    self.afterChange = kwargs.afterChange or function () end

    guiReference.Changed:Connect(function (newGui)
        self:onChanged(newGui)
    end)
    return self
end

function ShowOneGuiManager:onChanged(newGui)
    self.beforeChange(self, newGui)

    if self.currentGui then
        self.currentGui.Visible = false
    end

    if newGui then
        newGui.Visible = true
    end

    self.currentGui = newGui

    self.afterChange(self, newGui)
end

return ShowOneGuiManager