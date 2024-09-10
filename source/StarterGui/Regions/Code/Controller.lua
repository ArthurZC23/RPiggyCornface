local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local RootF = script:FindFirstAncestor("Code")
local View = require(RootF.View)

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local Controller = {}
Controller.__index = Controller
Controller.className = "Controller"
Controller.TAG_NAME = Controller.className

function Controller.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Controller)
    self._maid:Add(View.new(self))
    return self
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller