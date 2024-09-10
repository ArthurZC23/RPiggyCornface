local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})

local Bindables = ReplicatedStorage.Bindables
local Events = Bindables.Events
local ClientViewPortSizeChange = Events:WaitForChild("ClientViewPortSizeChange")

local camera = workspace.CurrentCamera
local recentVPSChanges = {}

local function propagateVPSizeChange()
    local BURST_DELAY = 0.1
    table.insert(recentVPSChanges, true)
    Promise.delay(BURST_DELAY)
        :andThen(function ()
            if #recentVPSChanges == 1 then ClientViewPortSizeChange:Fire() end
            table.remove(recentVPSChanges)
        end)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(propagateVPSizeChange)

local module = {}

return module