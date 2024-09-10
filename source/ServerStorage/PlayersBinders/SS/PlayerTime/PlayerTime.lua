local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local FastSpawn = Mod:find({"FastSpawn"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BigBen = Mod:find({"Cronos", "BigBen"})

local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local ScoresData = Data.Scores.Scores

local ONE_MINUTE = 60

local PlayerTime = {}
PlayerTime.__index = PlayerTime
PlayerTime.className = "PlayerTime"
PlayerTime.TAG_NAME = PlayerTime.className

function PlayerTime.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerTime)
    if not self:getFields() then return end

    self:setJoinTime()
    FastSpawn(function()
        self:updatePlayerTime()
    end)
    return self
end

function PlayerTime:setJoinTime()
    local state = self.playerState:get(S.Stores, "Time")
    local joinTime = Cronos:getTime()
    if not state.t00 then
        local action = {
            name = "SetFirstJoinTime",
            joinTime = joinTime
        }
        self.playerState:set(S.Stores, "Time", action)
    end
    do
        local action = {
            name = "SetJoinTime",
            joinTime = joinTime
        }
        self.playerState:set(S.Stores, "Time", action)
    end
end

function PlayerTime:updatePlayerTime()
    self._maid:Add2(BigBen.every(ONE_MINUTE, "Heartbeat", "time_", false):Connect(function()
        local action = {
            name = "increment",
            scoreType = ScoresData.scoreTypes.TimePlayed,
            timeType = ScoresData.timeTypes.allTime,
            value = 1
        }
        self.playerState:set(S.Stores, "Scores", action)
    end))
    Cronos.wait(ONE_MINUTE)
end

function PlayerTime:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerTime:Destroy()
    self._maid:Destroy()

end

return PlayerTime