local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local ServerTypesData = Data.Game.ServerTypes
local PlayerSessionScoresData = Data.Scores.PlayerScores.PlayerSessionScores
local S = Data.Strings.Strings
local ScoresData = Data.Scores.Scores

local KillerS = {}
KillerS.__index = KillerS
KillerS.className = "Killer"
KillerS.TAG_NAME = KillerS.className

function KillerS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, KillerS)

    if not self:getFields(char) then return end
    self._maid:Add(self:createRemotes())
    self._maid:Add(self:createSignals())
    self:handleKill()

    return self
end

function KillerS:createRemotes()
    return GaiaServer.createBinderRemotes(
        self,
        self.charEvents,
        {
            events = {},
            functions = {},
        }
    )
end

function KillerS:createSignals()
    return GaiaShared.createBinderSignals(self, self.charEvents, {
        events = {"Kill", "Assist"},
    })
end

function KillerS:handleKill()
    self._maid:Add(self.AssistSE:Connect(function()
        if ServerTypesData.isVipServer then
 
        else
            local action = {
                name = "increment",
                scoreType = ScoresData.scoreTypes.Assists,
                timeType = ScoresData.timeTypes.allTime,
                value = 1,
            }
            self.playerState:set(S.Stores, "Scores", action)
        end
    end))
    self._maid:Add(self.KillSE:Connect(function(killedPlayer, killedChar)
        if killedPlayer:GetAttribute("InDuel") then
            if not ServerTypesData.isVipServer then
                do
                    local action = {
                        name = "increment",
                        scoreType = "Duel",
                        timeType = "allTime",
                        value = 1,
                    }
                    self.playerState:set(S.Stores, "Scores", action)
                end
            end
            local playerSessionScoreId = PlayerSessionScoresData.scores.nameToId[S.PlayerDuelCurrentKillstreak].id
            do
                local action = {
                    name = "increment",
                    scoreType = playerSessionScoreId,
                    value = 1,
                }
                self.playerState:set(S.Session, "Scores", action)
            end
            if not ServerTypesData.isVipServer then
                do
                    local currentDuelKillstreak = self.playerState:get(S.Session, "Scores").scores[playerSessionScoreId]
                    local bestDuelKillStore = self.playerState:get(S.Stores, "Scores")[S.DuelBestKillstreak][S.allTime]
                    if currentDuelKillstreak > bestDuelKillStore then
                        do
                            local action = {
                                name = "set",
                                scoreType = S.DuelBestKillstreak,
                                timeType = S.allTime,
                                value = currentDuelKillstreak
                            }
                            self.playerState:set(S.Stores, "Scores", action)
                        end
                    end
                end
            end
            WaitFor.BObj(killedPlayer, "PlayerState"):now()
            :andThen(function(killedPlayerState)
                do
                    local action = {
                        name = "reset",
                        scoreType = playerSessionScoreId,
                    }
                    killedPlayerState:set(S.Session, "Scores", action)
                end
            end)
        else
            local playerSessionScoreId = PlayerSessionScoresData.scores.nameToId[S.PlayerArenaCurrentKillstreak].id
            do
                local action = {
                    name = "increment",
                    scoreType = playerSessionScoreId,
                    value = 1,
                }
                self.playerState:set(S.Session, "Scores", action)
            end
            if not ServerTypesData.isVipServer then
                local currentArenaKillstreak = self.playerState:get(S.Session, "Scores").scores[playerSessionScoreId]
                local bestArenaKillstreak = self.playerState:get(S.Stores, "Scores")[S.PlayerKillStreak][S.allTime]
                if currentArenaKillstreak > bestArenaKillstreak then
                    local action = {
                        name = "set",
                        scoreType = S.PlayerKillStreak,
                        timeType = S.allTime,
                        value = currentArenaKillstreak
                    }
                    self.playerState:set(S.Stores, "Scores", action)
                end
            end
            WaitFor.BObj(killedPlayer, "PlayerState"):now()
            :andThen(function(killedPlayerState)
                do
                    local action = {
                        name = "reset",
                        scoreType = playerSessionScoreId,
                    }
                    killedPlayerState:set(S.Session, "Scores", action)
                end
            end)
        end
        if not ServerTypesData.isVipServer then
            do
                local action = {
                    name = "increment",
                    scoreType = ScoresData.scoreTypes.Kills,
                    timeType = ScoresData.timeTypes.allTime,
                    value = 1,
                }
                self.playerState:set(S.Stores, "Scores", action)
            end
        end
    end))
end

function KillerS:getFields(char)
    local charType = CharUtils.getCharType(char)
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            do
                local bindersData = {
                    {"CharState", self.char},
                    {"CharParts", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            if charType == "PCharacter" then
                self.player = PlayerUtils:GetPlayerFromCharacter(char)
                if not self.player then return end

                local charId = self.char:GetAttribute("uid")
                self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
                if not self.charEvents then return end

                local bindersData = {
                    {"PlayerState", self.player},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function KillerS:Destroy()
    self._maid:Destroy()
end

return KillerS