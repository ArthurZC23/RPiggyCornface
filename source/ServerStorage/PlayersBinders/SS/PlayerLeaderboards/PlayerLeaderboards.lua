local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Math = Mod:find({"Math", "Math"})
local Queue = Mod:find({"DataStructures", "Queue"})
local Maid = Mod:find({"Maid"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local Data = Mod:find({"Data", "Data"})
local LeaderboardData = Data.Leaderboards.Leaderboards
local SuperUsers = Data.Players.Roles.HiddenRoles.HiddenRoles.SuperUsers
local ScoresData = Data.Scores.Scores
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local LeaderboardCodec = require(ServerStorage.Leaderboard.SS.LeaderboardCodec)

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local binderLeaderboard = SharedSherlock:find({"Binders", "getBinder"}, {tag="Leaderboard"})

local ONE_MINUTE = 60
--if RunService:IsStudio() then ONE_MINUTE = 10 end


local PlayerLeaderboards = {}
PlayerLeaderboards.__index = PlayerLeaderboards
PlayerLeaderboards.className = "PlayerLeaderboards"
PlayerLeaderboards.TAG_NAME = PlayerLeaderboards.className

function PlayerLeaderboards.new(player)
    local self = {}
    setmetatable(self, PlayerLeaderboards)
    self._maid = Maid.new()

    self.leaderboards = CollectionService:GetTagged("Leaderboard")

    -- discardNew
    -- replaceOld
    self.scheduler = JobScheduler.new(
        function(job)
            local kwargs = job.kwargs
            local ODataStore = kwargs.ODataStore
            local scoreData = kwargs.scoreData
            local compressedScore = LeaderboardCodec.encode(scoreData)
            local ok, err = pcall(function()
                --print("Sending compressed score: ", compressedScore)
                return ODataStore:SetAsync(player.UserId, compressedScore)
            end)
            -- This will clutter my error page. There is nothing I can do about this error. Should I remove it?
            if not ok then
                ErrorReport.report(
                    "", ("Failed to send player data to leaderboard. Error: %s"):format(tostring(err)), ErrorReport.severity.error)
            end
        end,
        "cooldown",
        {
            queueProps = {
                {},
                {
                    maxSize=#self.leaderboards,
                    fullQueueHandler=Queue.FullQueueHandlers.DiscardNew,
                    queueType=Queue.QueueTypes.FirstLastIdxs,
                },
            },
            schedulerProps = {
                cooldownFunc = function() return .25 * ONE_MINUTE end
            }
        }
    )

    FastSpawn(function()
        -- Don't let super user enter leaderboard in production.
        if
            game.PlaceId ~= 0
        then
            if SuperUsers[tostring(player.UserId)] then
                print("Blocked super user from entering the leaderboard.")
                return
            elseif tostring(player.UserId) == "1700355376" then
                print("Blocked Nazmar222 from entering the leaderboard.")
                return
            elseif player.UserId < 0 then
                print("Blocked Studio fake user from entering the leaderboard.")
            end
        end

        while player.Parent do
            self:pushLeaderboardJobs(player)
            Cronos.wait(ONE_MINUTE)
        end
    end)

    return self
end

function PlayerLeaderboards:pushLeaderboardJobs(player)
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
    if not playerState then return end

    for _, leaderboard in ipairs(self.leaderboards) do
        local id = leaderboard:GetAttribute("LeaderboardId")
        local leaderboardData = LeaderboardData[id]
        local scoreType = leaderboardData.scoreType
        local timeType = leaderboardData.timeType
        local ODataStore = leaderboardData.ODataStore

        local scoresState = playerState:get("Stores", "Scores")
        local scoreData = scoresState[ScoresData.scoreTypes[scoreType]][ScoresData.timeTypes[timeType]]
        local leaderboardObj = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderLeaderboard, inst=leaderboard})
        if self:isScoreEnoughForLeaderboard(leaderboardObj, leaderboardData, scoreData) then
            --self:updateLeaderboardInRealTime(leaderboardObj, scoreData)
            local job = {
                kwargs = {
                    ODataStore = ODataStore,
                    scoreData = scoreData,
                }
            }
            self.scheduler:pushJob(job)
        end
        -- print("Leaderboard")
        -- print(ScoresData.scoreTypes)
        -- print(ScoresData.scoreTypes)
        -- print(ScoresData.scoreTypes[scoreType])

    end
end

function PlayerLeaderboards:isScoreEnoughForLeaderboard(leaderboardObj, leaderboardData, scoreData)
    local entries = leaderboardObj.entries
    local numEntries = #entries
    if numEntries < leaderboardData.maxNumberEntries then return true end
    local lastEntry = entries[leaderboardData.maxNumberEntries]
    return scoreData > lastEntry.value
end

function PlayerLeaderboards:updateLeaderboardInRealTime(leaderboardObj, scoreData)
    -- Not trivial. Could cost a lot of processing power if I opt for the brute force approach and have a lot
    -- of leaderboards.
end

function PlayerLeaderboards:Destroy()
    self._maid:Destroy()
end

return PlayerLeaderboards