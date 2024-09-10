local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})
local _Data = require(script.Parent:WaitForChild("_Data"))

local Obby4SequenceGroupC = {}
Obby4SequenceGroupC.__index = Obby4SequenceGroupC
Obby4SequenceGroupC.className = "Obby4SequenceGroup"
Obby4SequenceGroupC.TAG_NAME = Obby4SequenceGroupC.className


function Obby4SequenceGroupC.new(RootFolder)
    if not RootFolder:FindFirstAncestor("Workspace") then return end
    local self = {
        _maid = Maid.new(),
        RootFolder = RootFolder,
    }
    setmetatable(self, Obby4SequenceGroupC)

    if not self:getFields() then return end
    self:startSequence()

    return self
end

local TableUtils = Mod:find({"Table", "Utils"})
function Obby4SequenceGroupC:startSequence()
    self._maid:Add(Promise.try(function()
        local obbyStates = _Data.idData[self.obbyId].obbyStates
        local numStates = TableUtils.len(obbyStates)
        local tweenDuration = 0.5
        local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        local goal = {}

        while true do
            for i = 1, numStates do
                local data = obbyStates[tostring(i)]
                for id, isOn in pairs(data._state) do
                    local Block = self.RootFolder[id]
                    if isOn then
                        local tween = TweenService:Create(Block, tweenInfo, {Orientation = Vector3.new(90, -180, 0)})
                        tween.Completed:Connect(function()
                            Block.CanCollide = true
                        end)
                        tween:Play()
                    else
                        local tween = TweenService:Create(Block, tweenInfo, {Orientation = Vector3.new(0, 90, -90)})
                        tween.Completed:Connect(function()
                            Block.CanCollide = false
                        end)
                        tween:Play()
                    end
                end
                task.wait(data.duration + tweenDuration)
            end
        end
    end))
end

function Obby4SequenceGroupC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.obbyId = self.RootFolder:GetAttribute("obbyId")
            if not self.obbyId then return end

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

function Obby4SequenceGroupC:Destroy()
    self._maid:Destroy()
end

return Obby4SequenceGroupC