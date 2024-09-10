local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})
local Functional = Mod:find({"Functional"})
local EzRefUtils = Mod:find({"EzRef", "Utils"})

local S = Data.Strings.Strings

local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 0
overlapParams.FilterDescendantsInstances = {workspace.Map}
overlapParams.FilterType = Enum.RaycastFilterType.Whitelist

local FindTeleporterS = {}
FindTeleporterS.__index = FindTeleporterS
FindTeleporterS.className = "FindTeleporter"
FindTeleporterS.TAG_NAME = FindTeleporterS.className

function FindTeleporterS.new(Teleporters)
    local self = {
        Teleporters = Teleporters,
        _maid = Maid.new(),
    }
    setmetatable(self, FindTeleporterS)

    if not self:getFields() then return end
    self:setTeleporter()

    return self
end

function FindTeleporterS:setTeleporter()
    local parts = Functional.filter(self.Teleporters:GetDescendants(), function(desc)
        return desc:IsA("BasePart")
    end)
    for _, part in ipairs(parts) do
        part.CanCollide = false
    end
    local teleportedIdx = Random.new():NextInteger(1, #parts)
    local teleporter = parts[teleportedIdx]
    teleporter.CanTouch = true
    if RunService:IsStudio() then
        teleporter.Color = Color3.fromRGB(255, 0, 0)
        teleporter.Material = Enum.Material.Neon
    end
    self._maid:Add2(teleporter.Touched:Connect(InstanceDebounce.playerLimbCooldownPerPlayer(
        function(player, char)
            local nextStageId = self.Teleporters:FindFirstAncestor("Obby").Parent:GetAttribute("ObbyStageId")
            nextStageId = tostring(tonumber(nextStageId) + 1)
            local nextStage = SharedSherlock:find({"EzRef", "GetSync"}, {inst = workspace.Map, refName=("ObbyStage_%s"):format(nextStageId)})
            local cf = nextStage.Start.Checkpoint.Skeleton.TeleportRef.CFrame +  5 * Vector3.yAxis
            char:PivotTo(cf)
        end,
        0.1,
        "R6"
    )))
end

function FindTeleporterS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.part.Parent
        end,
    })
    return ok
end

function FindTeleporterS:Destroy()
    self._maid:Destroy()
end

return FindTeleporterS