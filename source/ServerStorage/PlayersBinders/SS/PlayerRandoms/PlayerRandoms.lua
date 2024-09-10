local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local PlayerRandoms = {}
PlayerRandoms.__index = PlayerRandoms
PlayerRandoms.className = "PlayerRandoms"
PlayerRandoms.TAG_NAME = PlayerRandoms.className

function PlayerRandoms.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
        randoms = {},
    }
    setmetatable(self, PlayerRandoms)

    -- self:addMomentTokensRandoms()

    return self
end

-- function PlayerRandoms:addMomentTokensRandoms()
--     self.randoms["MomentsTokens"] = {}
--     for id, data in pairs(MomentsData.moments) do
--         self.randoms["MomentsTokens"][id] = Random.new()
--     end
-- end

function PlayerRandoms:Destroy()
    self._maid:Destroy()
end

return PlayerRandoms