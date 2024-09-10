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

local KeyLockDestroyPuzzleC = {}
KeyLockDestroyPuzzleC.__index = KeyLockDestroyPuzzleC
KeyLockDestroyPuzzleC.className = "KeyLockDestroyPuzzle"
KeyLockDestroyPuzzleC.TAG_NAME = KeyLockDestroyPuzzleC.className

function KeyLockDestroyPuzzleC.new(RootModel)
    if not RootModel:IsDescendantOf(workspace) then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, KeyLockDestroyPuzzleC)

    if not self:getFields() then return end
    self:handleFinishPuzzle()

    return self
end

function KeyLockDestroyPuzzleC:handleFinishPuzzle()
    self._maid:Add(self.puzzle.FinishPuzzleSE:Connect(function()
        for _, inst in ipairs(self.Barriers:GetChildren()) do
            if not inst:IsA("BasePart") then continue end
            inst.CanCollide = false
        end
        self.Model:Destroy()
    end))

    self.puzzle:handleTouch()
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function KeyLockDestroyPuzzleC:getFields()
    return WaitFor.GetAsync({
        getter=function()

            self.Barriers = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Barriers"})
            if not self.Barriers then return end

            self.Model = ComposedKey.getFirstDescendant(self.RootModel, {"Model", })
            if not self.Model then return end

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

function KeyLockDestroyPuzzleC:Destroy()
    self._maid:Destroy()
end

return KeyLockDestroyPuzzleC