local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local Click = {}
Click.__index = Click

function Click.new(button, kwargs)
	kwargs = kwargs or {}
    local self = {}
    setmetatable(self, Click)
    self._maid = Maid.new()
	self.button = button
    local hof = kwargs.hof or function (func) return func end
    self.onActivated = kwargs.onActivated
    self._maid:Add(button.Activated:Connect(hof(function (...) self:onActivated(...) end)))
    return self
end

function Click:Destroy()
    self._maid:Destroy()
end

return Click