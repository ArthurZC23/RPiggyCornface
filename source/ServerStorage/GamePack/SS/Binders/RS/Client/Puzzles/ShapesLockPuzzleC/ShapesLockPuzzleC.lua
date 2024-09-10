local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

local ShapesLockPuzzleC = {}
ShapesLockPuzzleC.__index = ShapesLockPuzzleC
ShapesLockPuzzleC.className = "ShapesLockPuzzle"
ShapesLockPuzzleC.TAG_NAME = ShapesLockPuzzleC.className

function ShapesLockPuzzleC.new(RootModel)
    if not RootModel:IsDescendantOf(workspace) then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, ShapesLockPuzzleC)

    if not self:getFields() then return end
    self:handleUseKey()
    self:handleFinishPuzzle()

    return self
end

function ShapesLockPuzzleC:handleUseKey()
    self._maid:Add(self.puzzle.UsePuzzleKeySE:Connect(function(keyId)
        local Model = ReplicatedStorage.Assets.Puzzles.Keys.KeySpawner[keyId]:Clone()
        for _, desc in ipairs(Model:GetDescendants()) do
            if not desc:IsA("BasePart") then continue end
            desc.Anchored = true
        end
        local shapeName = Data.Puzzles.Keys.idData[keyId].name
        Model:PivotTo(self.SShapes[shapeName]:GetPivot())
        Model.Parent = self.MShapes
    end))
end

function ShapesLockPuzzleC:handleFinishPuzzle()
    self._maid:Add(self.puzzle.FinishPuzzleSE:Connect(function()
        self.Front:Destroy()
        self.MShapes:Destroy()
    end))

    self.puzzle:handleTouch()
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function ShapesLockPuzzleC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.Front = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "Safe", "Front"})
            if not self.Front then return end

            self.MShapes = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "Shapes",})
            if not self.MShapes then return end

            self.SShapes = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Shapes",})
            if not self.SShapes then return end

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

function ShapesLockPuzzleC:Destroy()
    self._maid:Destroy()
end

return ShapesLockPuzzleC