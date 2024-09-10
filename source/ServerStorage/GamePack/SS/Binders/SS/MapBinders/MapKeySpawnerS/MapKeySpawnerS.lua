local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local function setAttributes()

end
setAttributes()

local MapKeySpawnerS = {}
MapKeySpawnerS.__index = MapKeySpawnerS
MapKeySpawnerS.className = "MapKeySpawner"
MapKeySpawnerS.TAG_NAME = MapKeySpawnerS.className

function MapKeySpawnerS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, MapKeySpawnerS)

    if not self:getFields() then return end
    -- self:spawnKeyInMap()
    self:setFx()
    self:handleSpawnInPlayerBackpack()

    return self
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function MapKeySpawnerS:setFx()
    -- Shows particles when stuff is hidden away (bad)

    -- local Particles = self._maid:Add2(ReplicatedStorage.Assets.Particles.KeyPickup:Clone())
    -- Particles.Name = "Particles"
    -- Particles.Parent = self.SRef

    -- GaiaShared.create("Highlight", {
    --     DepthMode = Enum.HighlightDepthMode.Occluded,
    --     Parent = self.RootModel,
    -- })

    GaiaShared.create("SelectionBox", {
        Color3 = Color3.fromRGB(13, 105, 172),
        LineThickness = 0.05,
        SurfaceColor3 = Color3.fromRGB(13, 105, 172),
        SurfaceTransparency = 0.8,
        Adornee = self.RootModel,
        Parent = self.RootModel,
    })
end

function MapKeySpawnerS:spawnKeyInMap()
    local Model = ReplicatedStorage.Assets.Puzzles.Keys.KeySpawner[self.keyId]:Clone()
    Model.Name = "Key"
    Model:PivotTo(self.RootModel:GetPivot())
    Model.Parent = self.RootModel.Model
end

local Promise = Mod:find({"Promise", "Promise"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
function MapKeySpawnerS:handleSpawnInPlayerBackpack()
    self.clickDetector = self._maid:Add(GaiaShared.create("ClickDetector", {
        MaxActivationDistance = 20,
        Parent = self.RootModel,
    }))
    self._maid:Add(self.clickDetector.MouseClick:Connect(function(player)
        local char = player.Character
        if not (char and char.Parent) then return end
        if char:HasTag("Monster") then return end

        local charState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharState", inst = char})
        if not charState then return end

        local mapPuzzleState = charState:get(S.Session, "MapPuzzles")
        if mapPuzzleState.keySt[self.keyId] then return end

        do
            local action = {
                name = "addKey",
                id = self.keyId,
            }
            charState:set(S.Session, "MapPuzzles", action)
        end

    end))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MapKeySpawnerS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.SRef = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "SRef"})
            if not self.SRef then return end

            local keyData = Data.Puzzles.Keys.nameData[self.RootModel.Name]

            self.keyId = keyData.id
            if not self.keyId then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=nil
    })
end

function MapKeySpawnerS:Destroy()
    self._maid:Destroy()
end

return MapKeySpawnerS