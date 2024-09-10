local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local Promise = Mod:find({"Promise", "Promise"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Data = Mod:find({"Data", "Data"})
local Badges = Data.Badges.Badges
local Maid = Mod:find({"Maid"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local Hooks = ServerStorage.Hooks.PlayerBadges

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerBadges = {}
PlayerBadges.__index = PlayerBadges
PlayerBadges.className = "PlayerBadges"
PlayerBadges.TAG_NAME = PlayerBadges.className

-- At the start check all badges and update stores state

function PlayerBadges.new(player)
    local self = {
        _maid = Maid.new(),
        player = player
    }
    setmetatable(self, PlayerBadges)

    self:createSignals()
    FastSpawn(function()
        self.playerState = binderPlayerState:getObj(player)
        if not self.playerState then return end

        self:loadBadges()
        self:handleBadgeAward()

        for _, child in ipairs(Hooks:GetChildren()) do
            local mod = require(child)
            task.spawn(function()
                self._maid:Add(mod.hook(self))
            end)
        end
    end)

    return self
end

function PlayerBadges:handleBadgeAward()
    self._maid:Add2(self.AwardBadgeSE:Connect(function(badgeId)
        if RunService:IsStudio() then
            print("awardBadge: ", badgeId)
        end
        self:awardBadge(badgeId)
    end))
end

function PlayerBadges:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.player, {
        events = {"AwardBadge"},
    }))
end

local function playerHasBadge(player, badgeId, waitPeriod)
    return Promise.new(function (resolve, reject)
        local ok, hasBadge = pcall(BadgeService.UserHasBadgeAsync, BadgeService, player.UserId, badgeId)
        if ok then
            resolve(hasBadge)
        else
            Promise.delay(waitPeriod):await()
            reject(("Could not load badge %s for player %s."):format(badgeId, player.Name))
        end
    end)
end

function PlayerBadges:loadBadges()
    local TOTAL_TRIES = 2
    local WAIT_PERIOD = 3
    for _, badgeId in pairs(Badges.nameToId) do
        Promise.retry(
            playerHasBadge,
            TOTAL_TRIES,
            self.player,
            badgeId,
            WAIT_PERIOD
        )
            :andThen(function (hasBadge)
                -- This is not used to actually award badges, but to propagate the badge award to other system like Guis.
                -- If badge is in playerState, you have the guarantee player has it
                if hasBadge then
                    local action = {
                        name="addBadge",
                        id = badgeId,
                    }
                    self.playerState:set("Stores", "Badges", action)
                end
            end)
            :catch(function (err)
                warn(tostring(err))
            end)
        --Cronos.wait(1)
    end
end

function PlayerBadges:awardBadge(badgeId)
    local TOTAL_TRIES = 3
    local WAIT_PERIOD = 3

    Promise.retry(
        playerHasBadge,
        TOTAL_TRIES,
        self.player,
        badgeId,
        WAIT_PERIOD
    )
        :andThen(function (hasBadge)
            if hasBadge == false then
                local ok, err = pcall(BadgeService.AwardBadge, BadgeService, self.player.UserId, badgeId)
                if ok then
                    local action = {
                        name="addBadge",
                        id = badgeId,
                    }
                    self.playerState:set("Stores", "Badges", action)
                else
                    error(tostring(err))
                end
            end
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
end

function PlayerBadges:Destroy()

end

return PlayerBadges