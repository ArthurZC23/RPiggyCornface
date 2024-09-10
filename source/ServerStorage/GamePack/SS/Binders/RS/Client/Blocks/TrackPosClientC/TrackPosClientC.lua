--[[
    It's a non reciprical weld. This follows the target cf, but not vice versa.
    For instance, I can make a spin wheel to follow a killblock skeleton.
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local TrackPosClientC = {}
TrackPosClientC.__index = TrackPosClientC
TrackPosClientC.className = "TrackPosClient"
TrackPosClientC.TAG_NAME = TrackPosClientC.className

function TrackPosClientC.new(inst)
    local self = {
        inst = inst,
        _maid = Maid.new(),
    }
    setmetatable(self, TrackPosClientC)

    if not self:getFields() then return end
    self:track()

    return self
end

local BigBen = Mod:find({"Cronos", "BigBen"})
function TrackPosClientC:track()
    self._maid:Add(BigBen.every(function() return self.inst:GetAttribute("TrackPosClientStep") or 1 end, "Heartbeat", "frame", true):Connect(function(_, timeStep)
        local theta = self.inst:GetAttribute("AngularVelocity") * timeStep
        self.inst:PivotTo(self.inst:GetPivot().Rotation * CFrame.Angles(theta.X, theta.Y, theta.Z) + self.Tracked:GetPivot().Position)
    end))
end

function TrackPosClientC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.Tracked = ComposedKey.getFirstDescendant(self.inst, {"Tracked"})
            if not self.Tracked then return end
            self.Tracked = self.Tracked.Value
            if not self.Tracked then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.inst.Parent
        end,
    })
    return ok
end

function TrackPosClientC:Destroy()
    self._maid:Destroy()
end

return TrackPosClientC