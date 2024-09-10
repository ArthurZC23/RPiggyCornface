local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local Exit = {}
Exit.__index = Exit

function Exit.new(exitButton, frame, kwargs)
    local self = {}
    setmetatable(self, Exit)
    self._maid = Maid.new()
	self.exitButton = exitButton
	self.frame = frame
	kwargs = kwargs or {}
    local hof = kwargs.hof or function (func)
        return func
    end
    self.onActivated = kwargs.onActivated or self.onActivated
    self._maid:Add(exitButton.Activated:Connect(
        hof(
            function (...)
                self:onActivated(...)
            end)
        )
    )
    return self
end

function Exit:onActivated()
    --local mainGui = MainGuiUtils.getMainGuiObj()
	--mainGui.Value = nil
	self.frame.Visible = false
end

function Exit:Destroy()
    self._maid:Destroy()
end

return Exit