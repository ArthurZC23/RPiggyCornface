local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Promise = Mod:find({"Promise", "Promise"})

local BlockMoveSequenceGroupC = {}
BlockMoveSequenceGroupC.__index = BlockMoveSequenceGroupC
BlockMoveSequenceGroupC.className = "BlockMoveSequenceGroup"
BlockMoveSequenceGroupC.TAG_NAME = BlockMoveSequenceGroupC.className

function BlockMoveSequenceGroupC.new(RootFolder)
    if not RootFolder:FindFirstAncestor("Workspace") then return end
    local self = {
        _maid = Maid.new(),
        RootFolder = RootFolder,
    }
    setmetatable(self, BlockMoveSequenceGroupC)

    if not self:getFields() then return end
    self:startSequence()

    return self
end

function BlockMoveSequenceGroupC:startSequence()
    self._maid:Add(Promise.try(function()
        while true do
            local seqSize = #self.Sequences[1]:GetChildren()
            for seqIdx = 1, seqSize do
                local promises = {}
                for skIdx, Sequence in ipairs(self.Sequences) do
                    local p = Promise.try(function()
                        local SequenceBlock = Sequence[seqIdx]
                        local SkPp = self.SkPps[skIdx]

                        local duration = SequenceBlock:GetAttribute("duration") or 1
                        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
                        local goal = {
                            CFrame = SequenceBlock.CFrame,
                        }
                        local tween = TweenService:Create(SkPp, tweenInfo, goal)
                        tween:Play()
                        tween.Completed:Wait()

                        local blockSequenceCooldown = SequenceBlock:GetAttribute("blockSequenceCooldown")
                        if blockSequenceCooldown then task.wait(blockSequenceCooldown) end
                    end)
                    table.insert(promises, p)
                end
                local ok, err = Promise.all(promises):await()
                if not ok then warn(tostring(err)) end
            end
        end
    end))
end

function BlockMoveSequenceGroupC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.Sequences = {}
            self.SkPps = {}

            for i, RootModel in ipairs(self.RootFolder:GetChildren()) do
                local Skeleton = ComposedKey.getFirstDescendant(RootModel, {"Skeleton"})
                if not Skeleton then return end

                local Sequence = Skeleton:FindFirstChild("Sequence")
                if not Sequence then return end
                table.insert(self.Sequences, Sequence)

                local SkPp = Skeleton.PrimaryPart
                if not SkPp then return end
                table.insert(self.SkPps, SkPp)
            end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootFolder.Parent
        end,
    })
    return ok
end

function BlockMoveSequenceGroupC:Destroy()
    self._maid:Destroy()
end

return BlockMoveSequenceGroupC