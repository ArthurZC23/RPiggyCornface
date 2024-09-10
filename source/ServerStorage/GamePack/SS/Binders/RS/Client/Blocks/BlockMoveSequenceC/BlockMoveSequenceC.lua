local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Promise = Mod:find({"Promise", "Promise"})

local BlockMoveSequenceC = {}
BlockMoveSequenceC.__index = BlockMoveSequenceC
BlockMoveSequenceC.className = "BlockMoveSequence"
BlockMoveSequenceC.TAG_NAME = BlockMoveSequenceC.className

function BlockMoveSequenceC.new(RootModel)
    if not RootModel:FindFirstAncestor("Workspace") then return end
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, BlockMoveSequenceC)

    if not self:getFields() then return end
    if RootModel:GetAttribute("isStickyBlock") then
        self:setStickyBlock()
    end
    self:startSequence()

    return self
end

function BlockMoveSequenceC:setStickyBlock()
    -- Necessary for player to follow block
    local lastPosition = self.PP.Position
    local lastVelocity = Vector3.zero
    local alpha = 0.7
    self._maid:Add(BigBen.every(1, "Stepped", "frame", false):Connect(function(_, timeStep)
        local currentPosition = self.PP.Position
        local deltaPos = currentPosition - lastPosition
        local velocity = deltaPos / timeStep

        self.PP.AssemblyLinearVelocity = alpha * velocity + (1 - alpha) * lastVelocity

        lastVelocity = velocity
        lastPosition = currentPosition
    end))

end

function BlockMoveSequenceC:startSequence()
    local Sequence = self.RootModel.Skeleton.Sequence
    local SequenceChildren = Sequence:GetChildren()
    self._maid:Add(Promise.try(function()
        while true do
            for i = 1, #SequenceChildren do
                local SequenceBlock = Sequence[i]
                local duration = SequenceBlock:GetAttribute("duration")
                if not duration then error("") end
                local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
                local goal = {
                    CFrame = SequenceBlock.CFrame,
                }
                local tween = TweenService:Create(self.SkPp, tweenInfo, goal)
                tween:Play()
                tween.Completed:Wait()

                local blockSequenceCooldown = SequenceBlock:GetAttribute("blockSequenceCooldown")
                if blockSequenceCooldown then task.wait(blockSequenceCooldown) end
            end
        end
    end))
end

function BlockMoveSequenceC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.Model = ComposedKey.getFirstDescendant(self.RootModel, {"Model"})
            if not self.Model then return end

            self.Skeleton = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton"})
            if not self.Skeleton then return end

            self.SkPp = self.Skeleton.PrimaryPart
            if not self.SkPp then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
    })
    return ok
end

function BlockMoveSequenceC:Destroy()
    self._maid:Destroy()
end

return BlockMoveSequenceC