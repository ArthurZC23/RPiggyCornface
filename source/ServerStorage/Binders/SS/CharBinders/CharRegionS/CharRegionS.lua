local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local RegionsData = Data.Regions.Regions
local CollisionsGroups = Data.Collisions.CollisionGroupsData
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

for _, region in ipairs(CollectionService:GetTagged("Region")) do
    -- print(region:GetFullName())
    region.Transparency = 1
    region.CanQuery = true
    region.CanTouch = false
    region.CanCollide = false
end

local CharRegion = {}
CharRegion.__index = CharRegion
CharRegion.className = "CharRegion"
CharRegion.TAG_NAME = CharRegion.className

function CharRegion.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharRegion)
    if not self:getFields() then return end
    FastSpawn(self.updateRegion, self, self.player, char)

    return self
end

function CharRegion:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end
            local bindersData = {
                {"CharState", self.char},
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharRegion:updateRegion(plr, char)
    local overlapParams = OverlapParams.new()
    overlapParams.CollisionGroup = "Regions"
    overlapParams.MaxParts = 0
    overlapParams.FilterDescendantsInstances = CollectionService:GetTagged("Region")
    overlapParams.FilterType = Enum.RaycastFilterType.Whitelist

    self._maid:Add(BigBen.every(RegionsData.pooling.cooldown, "Heartbeat", "time_", true):Connect(function()
        local parts = workspace:GetPartBoundsInBox(self.charParts.hrp.CFrame, self.charParts.hrp.Size, overlapParams)
        local currentRegions = {}
        for _, p in ipairs(parts) do
            --print("Part: ", p)
            local isRegion = CollectionService:HasTag(p, "Region")
            if not isRegion then continue end
            if currentRegions[p.Name] then
                warn(("Two regions cannot have the same name. %s"):format(p))
            end
            currentRegions[p.Name] = true
        end
        if not next(currentRegions) then
            currentRegions = {["RegionNil"]=true}
        end

        local newRegions = {}
        local removedRegions = {}
        local regionState = self.charState:get(S.Session, "Regions")
        for region in pairs(currentRegions) do
            if not regionState.regions[region] then
                newRegions[region] = true
            end
        end
        for region in pairs(regionState.regions) do
            if not currentRegions[region] then
                removedRegions[region] = true
            end
        end

        -- print("Regions: ")
        -- TableUtils.print(regionState.regions)
        -- print("Print New Regions: ")
        -- TableUtils.print(newRegions)
        -- print("Print Removed Regions: ")
        -- TableUtils.print(removedRegions)

        if next(removedRegions) then
            --print("Remove All regions")
            local action = {
                name="RemoveRegions",
                regions = removedRegions,
            }
            self.charState:set(S.Session, "Regions", action)
        end

        if next(newRegions) then
            --print("Add All regions")
            local action = {
                name="AddRegions",
                regions = newRegions,
            }
            self.charState:set(S.Session, "Regions", action)
        end
    end))
end

function CharRegion:regionRaycast(plr, char)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.FilterDescendantsInstances = {workspace.Map, workspace.Regions}
    raycastParams.CollisionGroup = CollisionsGroups.names.Regions
    raycastParams.IgnoreWater = true

    while self.char.Parent do
        Cronos.wait(RegionsData.raycast.period)
        local regionState = self.charState:get("Session", "Regions")
        local raycastResult = workspace:Raycast(self.hrp.Position, Vector3.new(0, -15, 0), raycastParams)
        if raycastResult then
            local region = raycastResult.Instance
            if regionState.region == RegionsData.regions[region.Name] then continue end
            local action = {
                name="setRegion",
                region=RegionsData.regions[region.Name]
            }
            self.charState:set("Session", "Regions", action)
        elseif regionState.region ~= RegionsData.regions["RegionNil"] then
            local action = {
                name="setRegion",
                region=RegionsData.regions["RegionNil"]
            }
            self.charState:set("Session", "Regions", action)
        end
    end
end

function CharRegion:Destroy()
    self._maid:Destroy()
end

return CharRegion