local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local BigBen = Mod:find({"Cronos", "BigBen"})

local CFrameDebug = {}
CFrameDebug.__index = CFrameDebug
CFrameDebug.className = "CFrameDebug"
CFrameDebug.TAG_NAME = CFrameDebug.className

function CFrameDebug.new(pvInst)
    local self = {
        pvInst = pvInst,
        _maid = Maid.new(),
    }
	setmetatable(self, CFrameDebug)
    self._maid:Add(BigBen.every)(1, "Heartbeat", "frame", false):Connect(function()
        local base
        if self.pvBaseInst then
            base = self.pvBaseInst:GetPivot()
        else
            base = CFrame.new()
        end

        local offsetValues = pvInst:GetAttribute("CFrameOffset")
        if not offsetValues then
            offsetValues = Vector3.new(0, 0, 0)
            pvInst:SetAttribute("CFrameOffset", offsetValues)
        end

        local anglesValues = pvInst:GetAttribute("CFrameAngles")
        if not anglesValues then
            anglesValues = Vector3.new(0, 0, 0)
            pvInst:SetAttribute("CFrameAngles", anglesValues)
        end

        local offset = CFrame.new(offsetValues)
        local angles = CFrame.Angles(anglesValues.X, anglesValues.Y, anglesValues.Z)
        -- pvInst:PivotTo((base * angles):ToWorldSpace(offset))
        pvInst:PivotTo(base:ToWorldSpace(offset):ToWorldSpace(angles))
    end)
    return self
end

function CFrameDebug:addCFrameBasePvInst(pvInst)
    self.pvBaseInst = pvInst
end

function CFrameDebug:Destroy()
    self._maid:Destroy()
end

return CFrameDebug