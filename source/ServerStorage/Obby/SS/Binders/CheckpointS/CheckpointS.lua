local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})
local S = Data.Strings.Strings

local CheckpointS = {}
CheckpointS.__index = CheckpointS
CheckpointS.className = "Checkpoint"
CheckpointS.TAG_NAME = CheckpointS.className

function CheckpointS.new(Checkpoint)
    local self = {
        Checkpoint = Checkpoint,
        _maid = Maid.new(),
    }
    setmetatable(self, CheckpointS)

    if not self:getFields() then return end
    self:handleStartStage()

    return self
end

function CheckpointS:handleStartStage()
    self._maid:Add2(self.Checkpoint.Skeleton.TeleportActivation.Touched:Connect(InstanceDebounce.playerLimbCooldownPerPlayer(
        function(player)
            WaitFor.BObj(player, "PlayerState")
            :now()
            :andThen(function(playerState)
                local stageModel = self.Checkpoint:FindFirstAncestor("Start").Parent
                local stageId = stageModel:GetAttribute("ObbyStageId") or ""
                local currentStageId = playerState:get(S.Session, "ObbyStage").stage
                if tonumber(stageId) > tonumber(currentStageId) then
                    local action = {
                        name = "setStage",
                        value = stageId
                    }
                    playerState:set(S.Session, "ObbyStage", action)
                end
            end)
        end,
        0.5,
        "R6"
    )))
end

function CheckpointS:getFields()
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

function CheckpointS:Destroy()
    self._maid:Destroy()
end

return CheckpointS