local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local UpdateLeaderstats = Data.Scores.UpdateLeaderstats
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local GaiaShared = Mod:find({"Gaia", "Shared"})

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerLeaderstats = {}
PlayerLeaderstats.__index = PlayerLeaderstats
PlayerLeaderstats.className = "PlayerLeaderstats"
PlayerLeaderstats.TAG_NAME = PlayerLeaderstats.className


function PlayerLeaderstats.new(player)
    local self = {
        player = player
    }
    setmetatable(self, PlayerLeaderstats)
    self:createLeaderstatsFolder()
    self:initializeLeaderstats()

    return self
end

function PlayerLeaderstats:createLeaderstatsFolder()
    self.leaderstats = GaiaShared.create("Folder", {
        Name = "leaderstats",
        Parent = self.player,
    })
end

function PlayerLeaderstats:initializeLeaderstats()
    local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=self.player})
    if not playerState then return end

    for _, stat in ipairs(UpdateLeaderstats) do
        if stat.stateManager ~= "playerState" then continue end
        local statV = GaiaShared.create(stat.type_, {
            Name = stat.prettyName,
            Parent = self.leaderstats,
        })
        playerState:getEvent(stat.stateType, stat.scope, stat.eventName):Connect(function(state, action)
            if playerState.isDestroyed then return end
            stat.update(statV, state, action, playerState)
        end)
        stat.update(statV, playerState:get(stat.stateType, stat.scope), playerState)
    end
end

function PlayerLeaderstats:Destroy()

end

return PlayerLeaderstats