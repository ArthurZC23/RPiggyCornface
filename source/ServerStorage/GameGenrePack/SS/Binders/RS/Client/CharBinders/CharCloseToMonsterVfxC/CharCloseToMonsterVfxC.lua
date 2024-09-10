local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local CharCloseToMonsterVfxC = {}
CharCloseToMonsterVfxC.__index = CharCloseToMonsterVfxC
CharCloseToMonsterVfxC.className = "CharCloseToMonsterVfx"
CharCloseToMonsterVfxC.TAG_NAME = CharCloseToMonsterVfxC.className

local function setAttributes()
    script:SetAttribute("MonsterRadius", 128)
end
setAttributes()

function CharCloseToMonsterVfxC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end
    if char:HasTag("PlayerMonster") then return end

    local self = {
        char = char,
        _maid = Maid.new(),
        keysTool = {},
    }
    setmetatable(self, CharCloseToMonsterVfxC)

    if not self:getFields() then return end
    self:addDetector()
    self:handleCloseToMonsterVfx()

    return self
end

function CharCloseToMonsterVfxC:addDetector()
    self.MonsterDetector = self._maid:Add2(ReplicatedStorage.Assets.Models.MonsterDetector:Clone())
    self.MonsterDetector:SetAttribute("transpDefault", 1)
    self.MonsterDetector:PivotTo(self.charParts.hrp:GetPivot())
    self.MonsterDetectorPart = self.MonsterDetector.Model.Part
    GaiaShared.create("WeldConstraint", {
        Part0 = self.charParts.hrp,
        Part1 = self.MonsterDetector.Skeleton.SRef,
        Parent = self.MonsterDetector.Skeleton.SRef,
    })
    self.MonsterDetector.Parent = self.char
end

local BigBen = Mod:find({"Cronos", "BigBen"})

local CollectionService = game:GetService("CollectionService")
local Functional = Mod:find({"Functional"})
local Bach = Mod:find({"Bach", "Bach"})
function CharCloseToMonsterVfxC:handleCloseToMonsterVfx()
    local overlapParams = OverlapParams.new()
    -- overlapParams.CollisionGroup = ""
    overlapParams.MaxParts = 0
    overlapParams.FilterType = Enum.RaycastFilterType.Whitelist

    self._maid:Add(BigBen.every(15, "Heartbeat", "frame", true):Connect(function()
        self.MonsterDetectorPart.Size = Vector3.new(16, script:GetAttribute("MonsterRadius"), script:GetAttribute("MonsterRadius"))
        local monsterHrps = Functional.filterThenMap(CollectionService:GetTagged("Monster"),
            function(monster)
                if not monster:IsDescendantOf(workspace) then return end
                local hrp = monster:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                return true
            end,
            function(monster)
                return monster:FindFirstChild("HumanoidRootPart")
            end
        )
        overlapParams.FilterDescendantsInstances = monsterHrps
        local allMonsterHrpInRange = workspace:GetPartsInPart(self.MonsterDetectorPart, overlapParams)

        if not next(allMonsterHrpInRange) then
            -- Bach:stop("Heartbeat", Bach.SoundTypes.Sfx)
            return
        end
        for _, monsterHrpInRange in ipairs(allMonsterHrpInRange) do
            local distance = (self.charParts.hrp.Position - monsterHrpInRange.Position).Magnitude + 1e-5
            local maxDistance = script:GetAttribute("MonsterRadius")
            -- Bach:play("Heartbeat", Bach.SoundTypes.Sfx, {
            --     soundProps = {
            --         PlaybackSpeed = math.max(0.5 - 0.4/maxDistance * distance, 0.8),
            --         Volume = math.max(2 - 1/maxDistance * distance, 2),
            --     }
            -- })
        end
    end))
end

function CharCloseToMonsterVfxC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
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
        cooldown=1
    })
    return ok
end

function CharCloseToMonsterVfxC:Destroy()
    self._maid:Destroy()
end

return CharCloseToMonsterVfxC