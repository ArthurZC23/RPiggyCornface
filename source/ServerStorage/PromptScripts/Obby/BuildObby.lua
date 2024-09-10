local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local Data = ServerStorage.Data.SS.Data
local ObbyData = require(Data.Obby.Obby:Clone())

local ObbyStages = ServerStorage.Assets.Obby.Stages

local Obby = Instance.new("Model")
Obby.Name = "Obby"

local Stages = ServerStorage.Assets.Obby.Stages
for _, stage in ipairs(Stages:GetChildren()) do
    CollectionService:RemoveTag(stage, "EzRef")
    local refData = stage:FindFirstChild("RefData")
    if refData then
        refData:Destroy()
    end
end

local obbyStartPlace = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
local previousFinisher
local obbyStageId = ObbyData.firstStageId
local idx = 1
while obbyStageId do
    local obbyStageData = ObbyData.stages[obbyStageId]
    obbyStageId = tostring(obbyStageId)
    local stage = ObbyStages[obbyStageData.stage]:Clone()
    local realObbyStageId = tostring(idx)
    stage.PrimaryPart = stage.Start.Checkpoint.Skeleton.TeleportRef
    if obbyStageData.cf then
        stage:PivotTo(obbyStageData.cf)
    elseif previousFinisher then
        local cf = previousFinisher:GetPivot()
        if obbyStageData.start and obbyStageData.start.offset then
            cf = cf * obbyStageData.start.offset
        end
        stage:PivotTo(cf)
    else
        stage:PivotTo(obbyStartPlace)
    end
    stage:SetAttribute("ObbyStageId", realObbyStageId)

    local RefData = Instance.new("Folder")
    RefData.Name = "RefData"
    RefData.Parent = stage

    local RefName = Instance.new("StringValue")
    RefName.Name = "RefName"
    RefName.Value = ("ObbyStage_%s"):format(realObbyStageId)
    RefName.Parent = RefData

    CollectionService:AddTag(stage, "EzRef")

    stage.Parent = Obby
    previousFinisher = stage.Finish.Skeleton.NextStart

    obbyStageId = obbyStageData._next
    idx += 1
end

Obby.Parent = workspace.Map


-- stage.Name = realObbyStageId -- Keep the stage name