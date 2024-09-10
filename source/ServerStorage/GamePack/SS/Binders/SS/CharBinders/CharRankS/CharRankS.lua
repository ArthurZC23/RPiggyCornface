local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local TableUtils = Mod:find({"Table", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharRankS = {}
CharRankS.__index = CharRankS
CharRankS.className = "CharRank"
CharRankS.TAG_NAME = CharRankS.className

function CharRankS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharRankS)

    if not self:getFields() then return end
    self:handleRank()

    return self
end

function CharRankS:handleRank()
    task.spawn(function()
        while self.char.Parent do
            local bestRank = "1"
            local bestRankPoints = 0
            local points = self.playerState:get(S.Stores, "Points").current
            for id, data in pairs(Data.Ranks.Ranks.idData) do
                if points > data.points and data.points > bestRankPoints then
                    bestRank = id
                    bestRankPoints = data.points
                end
            end
            do
                local action = {
                    name = "set",
                    id = bestRank
                }
                self.playerState:set(S.Session, "Rank", action)
            end
            task.wait(4)
        end
    end)
end


function CharRankS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {},
        functions = {},
    }))
end

function CharRankS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharRankS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharParts", self.char},
                {"CharState", self.char},
                {"CharProps", self.char},
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharRankS:Destroy()
    self._maid:Destroy()
end

return CharRankS