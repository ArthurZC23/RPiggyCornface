local LogService = game:GetService("LogService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Queue = Mod:find({"DataStructures", "Queue"})
local Data = Mod:find({"Data", "Data"})
local ErrorReportData = Data.ErrorReport.ErrorReport
local MegaPackRs = ReplicatedStorage:WaitForChild("MegaPack")
local ErrorReportShared = MegaPackRs:WaitForChild("ErrorReport"):WaitForChild("Shared")
local Filters = require(ErrorReportShared:WaitForChild("Filters"):WaitForChild("Filters"))

local LogErrorReportRE = ReplicatedStorage.Remotes.Events:WaitForChild("LogErrorReport")
local MethodErrorReportRE = ReplicatedStorage.Remotes.Events:WaitForChild("MethodErrorReport")

local localPlayer = Players.LocalPlayer

local scheduler = JobScheduler.new(
        function(job)
            local message = job[1]
            -- print("LogErrorReportRE:FireServer")
            LogErrorReportRE:FireServer(message)
        end,
        "cooldown",
        {
            queueProps = {
                {},
                {
                    maxSize=100,
                    fullQueueHandler=Queue.FullQueueHandlers.DiscardNew,
                    queueType=Queue.QueueTypes.FirstLastIdxs,
                }
            },
            schedulerProps = {
                cooldownFunc = function() return ErrorReportData.Client.cooldown + 15 end
            }
        }
    )

LogService.MessageOut:Connect(function(message, messageType)
    if messageType ~= Enum.MessageType.MessageError then return end
    if #message > 8192 then message = string.sub(message, 1, 8192) end
    -- print("Message before filter ", message)
    message = Filters.filterMessageClient(message)
    -- print("Pass client filter", message)
    if not message then return end
    scheduler:pushJob({message})
end)

local module = {}

-- User could also call this method and spam errors.
-- Let them spam errors if they want because it their bandwith, but filter
-- On server if not enough time has passed
-- Since th
function module.report(id, message, severity)
    -- if id == nil or id == "" then
    --     id = localPlayer.UserId
    -- end
    -- MethodErrorReportRE:FireServer(id, message, severity)

    message = debug.traceback(message, 2)
    task.spawn(function()
        error(message)
    end)
end

-- if RunService:IsStudio() then
--     task.spawn(function()
--         while true do
--             task.spawn(function()
--                 error("Error every frame")
--             end)
--             task.wait(2)
--         end
--     end)
-- end

return module