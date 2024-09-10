local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local Badges = Data.Badges.Badges
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Maid = Mod:find({"Maid"})
local S = Data.Strings.Strings
local Promise = Mod:find({"Promise", "Promise"})

local module = {}

function module.hook(self)
    local maid = Maid.new()
    maid:Add(WaitFor.BObj(self.player, "PlayerState"):andThen(function(playerState)
        local totalDuration = 30
        local sessionDuration = 15 * 60
        if self.player.UserId == 925418276 then
            totalDuration = 1
            sessionDuration = 15
        end
        local function update(state)
            if state.TimePlayed.allTime >= totalDuration then
                self:awardBadge(Badges.nameToId["Played_30MinTotal"])
                maid:Remove("TotalTime")
            end
        end
        maid:Add2(playerState:getEvent(S.Stores, "Scores", "increment"):Connect(update), "TotalTime")
        local state = playerState:get(S.Stores, "Scores")
        update(state)


        local sessionBadgeId = Badges.nameToId["Played_15MinSession"]
        local ok, hasBadge = pcall(BadgeService.UserHasBadgeAsync, BadgeService, self.player.UserId, sessionBadgeId)
        if not (ok and hasBadge) then
            maid:Add2(Promise.delay(sessionDuration):andThen(function()
                self:awardBadge(Badges.nameToId["Played_15MinSession"])
            end))
        end
    end))
    return maid
end

return module