local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Debounce = Mod:find({"Debounce", "Debounce"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local CollisionsGroups = Data.Collisions.CollisionGroupsData
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})
local binderHitDetector = SharedSherlock:find({"Binders", "getBinder"}, {tag="HitDetector"})
local localPlayer = Players.LocalPlayer

local CharSpatialAwareness = {}
CharSpatialAwareness.__index = CharSpatialAwareness
CharSpatialAwareness.className = "CharSpatialAwareness"
CharSpatialAwareness.TAG_NAME = CharSpatialAwareness.className

function CharSpatialAwareness.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        char = char,
        _maid = Maid.new()
    }
    setmetatable(self, CharSpatialAwareness)

    if not self:getFields() then return end
    self._maid:Add(self:refreshTarget())

    return self
end

function CharSpatialAwareness:refreshTarget()
    return self:_refreshTargetSpatialQuery()
end

function CharSpatialAwareness:_refreshTargetSpatialQuery()
    local overlapParams = OverlapParams.new()
    overlapParams.CollisionGroup = CollisionsGroups.names.HitDetector
    overlapParams.MaxParts = 1
    overlapParams.FilterDescendantsInstances = {self.playerArea}
    overlapParams.FilterType = Enum.RaycastFilterType.Whitelist

    return RunService.Stepped:Connect(function()
        local parts = workspace:GetPartsInPart(self.punchToucher, overlapParams)
        if next(parts) then
            local _, p = next(parts)
            local targetableObj = binderHitDetector:getObj(p)
            if targetableObj then
                self.targetObj = targetableObj
                self.target = p
            else
                self.targetObj = nil
                self.target = nil
            end
        else
            self.targetObj = nil
            self.target = nil
            return
        end
    end)
end

function CharSpatialAwareness:_refreshTargetHrpRay()

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.FilterDescendantsInstances = {self.playerArea}
    raycastParams.IgnoreWater = true
    raycastParams.CollisionGroup = CollisionsGroups.names.HitDetector

    -- local debugRayPart = GaiaShared.create("Part", {
    --     Anchored = true,
    --     CanCollide = false,
    --     Color = Color3.fromRGB(255, 0, 0),
    --     Transparency = 0.5,
    -- })

    return RunService.Stepped:Connect(function()
        local raycastResult = workspace:Raycast(self.hrp.Position, 3 * self.hrp.CFrame.LookVector, raycastParams)
        -- debugRayPart.Position = self.hrp.Position
        if raycastResult then
            local instance = raycastResult.Instance
            -- print("Aware:", instance:GetFullName())
            local targetableObj = binderHitDetector:getObj(instance)
            if targetableObj then
                self.targetObj = targetableObj
                self.target = instance
            else
                self.targetObj = nil
                self.target = nil
            end
        else
            self.targetObj = nil
            self.target = nil
        end
    end)
end

function CharSpatialAwareness:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            self.hrp = self.charParts.hrp
            self.punchToucher = self.charParts.punchToucher

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharSpatialAwareness:Destroy()
    self._maid:Destroy()
end

return CharSpatialAwareness