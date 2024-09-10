local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Welder = Mod:find({"Welder"})

local Weld = {}
Weld.__index = Weld
Weld.TAG_NAME = "Weld"

function Weld.new(obj)
    --if not obj:FindFirstAncestorOfClass("Workspace") then return end
	local self = {}
	setmetatable(self, Weld)
    self.obj = obj
    Welder.weld(obj)
	return self
end

function Weld:Destroy()
end

return Weld