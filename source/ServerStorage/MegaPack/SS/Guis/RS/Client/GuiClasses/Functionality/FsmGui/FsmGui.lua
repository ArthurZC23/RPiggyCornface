local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

-- Keep gui references for the callbacks to do the work on it.
local StateMachineGui = {}
StateMachineGui.__index = StateMachineGui

function StateMachineGui.new(guiObj, fsm, kwargs)
    local self = {}
    setmetatable(self, StateMachineGui)
    self.guiObj = guiObj
    self.fsm = fsm
    self.kwargs = kwargs or {}
    self._maid = Maid.new()
    return self
end

return StateMachineGui