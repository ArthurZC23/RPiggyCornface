local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local ScoresData = Data.Scores.Scores
local UpdateScores = Data.Scores.UpdateScores
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local PlayerScoresS = {}
PlayerScoresS.__index = PlayerScoresS
PlayerScoresS.className = "PlayerScores"
PlayerScoresS.TAG_NAME = PlayerScoresS.className

function PlayerScoresS.new(player)
    local self = {
        _maid = Maid.new(),
        charScoresCache = {},
    }
    setmetatable(self, PlayerScoresS)

    FastSpawn(function()
        local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
        if not playerState then return end
        self:updateScores(playerState)
    end)

    return self
end


function PlayerScoresS:updateScores(playerState)
    -- Careful with this. Since it only works with increments if the score source is updated before these listeners are on
    -- You're going to loose an increment. This is not a big deal but is good to keep in mind.

    for _, scoreData in ipairs(UpdateScores) do
        playerState:getEvent(scoreData.stateType, scoreData.scope, scoreData.event):Connect(function(_, incomingAction)
            local actionName = scoreData.actionName or "increment"
            local action = {
                name = actionName,
                scoreType = ScoresData.scoreTypes[scoreData.scoreType],
                timeType = ScoresData.timeTypes.allTime,
                value = incomingAction[scoreData.valueKey]
            }
            playerState:set("Stores", "Scores", action)
        end)
    end
end

function PlayerScoresS:Destroy()
    self._maid:Destroy()
end

return PlayerScoresS