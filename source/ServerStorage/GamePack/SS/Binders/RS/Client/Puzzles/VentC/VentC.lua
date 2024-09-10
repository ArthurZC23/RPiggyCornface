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
local Promise = Mod:find({"Promise", "Promise"})

local function setAttributes()

end
setAttributes()

local VentC = {}
VentC.__index = VentC
VentC.className = "Vent"
VentC.TAG_NAME = VentC.className

function VentC.new(RootModel)
    if not RootModel:IsDescendantOf(workspace) then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, VentC)

    if not self:getFields() then return end
    self:handleFinishPuzzle()

    return self
end

function VentC:handleFinishPuzzle()
    self._maid:Add(self.puzzle.FinishPuzzleSE:Connect(function()
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
        local goal = {
            CFrame = self.HingeCf1.CFrame
        }
        local tween = TweenService:Create(self.Hinge, tweenInfo, goal)
        Promise.fromEvent(tween.Completed)
        :andThen(function()
            self.Barrier.CanCollide = false
        end)
        self.OpenSfx:Play()
        tween:Play()
    end))

    self.puzzle:handleTouch()
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function VentC:getFields()
    return WaitFor.GetAsync({
        getter=function()

            self.Hinge = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Hinge"})
            if not self.Hinge then return end

            self.HingeCf1 = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "HingeCf1"})
            if not self.HingeCf1 then return end

            self.Barrier = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Barrier"})
            if not self.Barrier then return end

            self.OpenSfx = ComposedKey.getFirstDescendant(self.Barrier, {"Open"})
            if not self.OpenSfx then return end

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

function VentC:Destroy()
    self._maid:Destroy()
end

return VentC