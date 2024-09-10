local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local function setAttributes()

end
setAttributes()

local BridgePuzzleC = {}
BridgePuzzleC.__index = BridgePuzzleC
BridgePuzzleC.className = "BridgePuzzle"
BridgePuzzleC.TAG_NAME = BridgePuzzleC.className

function BridgePuzzleC.new(RootModel)
    if not RootModel:IsDescendantOf(workspace) then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
        keys = {},
    }
    setmetatable(self, BridgePuzzleC)

    if not self:getFields() then return end
    self:handleFinishPuzzle()

    return self
end

function BridgePuzzleC:handleFinishPuzzle()
    self._maid:Add(self.puzzle.FinishPuzzleSE:Connect(function()
        for _, part in ipairs(self.Barriers:GetChildren()) do
            part.CanCollide = false
        end
        for _, part in ipairs(self.Planks:GetChildren()) do
            part.CanCollide = true
            part.Transparency = 0
        end
    end))

    self.puzzle:handleTouch()
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function BridgePuzzleC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.Barriers = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Barriers"})
            if not self.Barriers then return end

            self.Planks = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "Planks"})
            if not self.Planks then return end

            local bindersData = {
                {"Puzzle", self.RootModel},
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

function BridgePuzzleC:Destroy()
    self._maid:Destroy()
end

return BridgePuzzleC