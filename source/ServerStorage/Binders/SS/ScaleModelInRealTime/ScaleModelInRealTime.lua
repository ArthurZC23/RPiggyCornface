local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Mosby = Mod:find({"Mosby", "Mosby"})

local ScaleModelInRealTime = {}
ScaleModelInRealTime.__index = ScaleModelInRealTime
ScaleModelInRealTime.className = "ScaleModelInRealTime"
ScaleModelInRealTime.TAG_NAME = ScaleModelInRealTime.className

-- Doesn't work. Keep 
function ScaleModelInRealTime.new(model)
    local self = {
        model = model,
        _maid = Maid.new(),
        scale = Vector3.new(1, 1, 1),
        invertedScale = Vector3.new(1, 1, 1),
    }
	setmetatable(self, ScaleModelInRealTime)
    self._maid:Add(BigBen.every(50, "Heartbeat", "frame", false):Connect(function()
        local newScale = model:GetAttribute("Scale")
        if not newScale then return end
        if newScale.Magnitude == 0 then return end
        if self.scale.Magnitude == newScale.Magnitude then return end

        local correctScale = newScale / self.invertedScale
        Mosby.scaleModel(model, correctScale)
        self.scale = newScale
        self.invertedScale = 1 / newScale
    end))
    return self
end

function ScaleModelInRealTime:Destroy()
    self._maid:Destroy()
end

return ScaleModelInRealTime