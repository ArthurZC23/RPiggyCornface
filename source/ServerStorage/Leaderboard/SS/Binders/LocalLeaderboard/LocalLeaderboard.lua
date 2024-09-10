local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local ScoresData = Data.Scores.Scores
local SignalE = Mod:find({"Signal", "Event"})
local FastSpawn = Mod:find({"FastSpawn"})
local Cronos = Mod:find({"Cronos", "Cronos"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local ONE_MINUTE = 60
if RunService:IsStudio() then
    -- ONE_MINUTE = 10
end

local LocalLeaderboard = {}
LocalLeaderboard.__index = LocalLeaderboard
LocalLeaderboard.className = "LocalLeaderboard"
LocalLeaderboard.TAG_NAME = LocalLeaderboard.className

function LocalLeaderboard.new()
    local self = {
        _maid = Maid.new(),
        leaderboards = {},
    }
    setmetatable(self, LocalLeaderboard)

    for scoreType in pairs(ScoresData.scoreTypes) do
        self.leaderboards[scoreType] = {}
    end

    self.updateLocalLeaderboardsSE = self._maid:Add(SignalE.new())

    FastSpawn(function()
        self:updateScores()
    end)

    return self
end

function LocalLeaderboard:updateScores()
    while true do
        --print("RANKS SORT")
        for scoreType in pairs(ScoresData.scoreTypes) do
            local ranks = {}
            for _, player in ipairs(Players:GetPlayers()) do
                local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=player})
                if not playerState then continue end
                local scoresState = playerState:get(S.Stores, "Scores")
                local score = scoresState[scoreType][ScoresData.timeTypes.allTime]
                table.insert(ranks, {
                    player = player,
                    score = score,
                })
            end
            -- local TableUtils = Mod:find({"Table", "Utils"})
            -- TableUtils.deepCopy(ranks)
            local ok, err = pcall(function()
                table.sort(ranks, function (a, b)
                    return a.score > b.score
                end)
            end)
            if not ok then
                local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
                local message = err
                for _, rank in ipairs(ranks) do
                    message = ("%s\nplayer: %s, rank: %s"):format(message, rank.player.Name, rank.score)
                end
                ErrorReport.report(nil, message, "warning")
                warn(err, message)
            end

            self.leaderboards[scoreType] = ranks
        end
        -- local TableUtils = Mod:find({"Table", "Utils"})
        -- TableUtils.print(self.leaderboards)
        self.updateLocalLeaderboardsSE:Fire()
        Cronos.wait(ONE_MINUTE)
    end
end

function LocalLeaderboard:Destroy()
    self._maid:Destroy()
end

return LocalLeaderboard