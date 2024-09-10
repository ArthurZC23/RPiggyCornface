local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local ParentFolder = script.Parent
local Utils = require(ParentFolder.DilatationUtils)

local function onEntered(guiObj, guiSize, kwargs)
    return function()
        Utils.expand(guiObj, guiSize, kwargs)
    end
end

local function onLeft(guiObj, guiSize, kwargs)
    return function()
        Utils.shrink(guiObj, guiSize, kwargs)
    end
end

local Dilatation = {}
Dilatation.__index = Dilatation

function Dilatation.new(guiObj, kwargs)
    local self = {}
    setmetatable(self, Dilatation)
	self.guiObj = guiObj
	kwargs = kwargs or {}
    self._maid = Maid.new()
    self._maid:Add(guiObj.MouseEnter:Connect(onEntered(guiObj, guiObj.Size, kwargs)))
    self._maid:Add(guiObj.MouseLeave:Connect(onLeft(guiObj, guiObj.Size, kwargs)))
    return self
end

function Dilatation:Destroy()
    self._maid:Destroy()
end

return Dilatation