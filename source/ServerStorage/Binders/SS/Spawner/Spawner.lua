local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})

local Data = Mod:find({"Data", "Data"})
local SpawnerData = Data.Spawner.Spawner

local Spawner = {}
Spawner.__index = Spawner
Spawner.className = "Spawner"
Spawner.TAG_NAME = Spawner.className

-- There should be no spawn in spawner before the class run.
function Spawner.new(sp)
    local self = {}
    setmetatable(self, Spawner)
    self._maid = Maid.new()

    self.sp = sp
    self.area = sp.Area
    self.data = SpawnerData[sp:GetAttribute("SpawnId")]
    self.proto = self.data.model

    self:spawnNew()

    return self
end

function Spawner:spawnNew()
    local model = self.proto:Clone()
    CollectionService:AddTag(model, "SpawnInst")
    self._maid:Add(
        Promise.fromEvent(
            model.PrimaryPart.AncestryChanged,
            function(_, parent)
                return parent == nil
            end
        ):andThen(function()
            Promise.delay(self.data.cooldown):andThen(function()
                self:spawnNew()
            end)
        end),
        "cancel",
        "SpawnRemoval"
    )

    local areaInternalPos =
        self.area.Position
        + Random.new():NextNumber(-0.5, 0.5) * self.area.Size * Vector3.new(1, 0, 1)

    model:PivotTo(
        model.PrimaryPart.CFrame
        - model.PrimaryPart.CFrame.Position
        + areaInternalPos
    )

    model.Parent = self.sp
end

function Spawner:Destroy()
    self._maid:Destroy()
end

return Spawner