local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Functional = Mod:find({"Functional"})
local TableUtils = Mod:find({"Table", "Utils"})
local Iterators = Mod:find({"Iterators", "Array"})
local SingletonsManager = Mod:find({"Singleton", "Manager"})

local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})

local CharsDistancesC = {}
CharsDistancesC.__index = CharsDistancesC
CharsDistancesC.className = "CharsDistances"
CharsDistancesC.TAG_NAME = CharsDistancesC.className

function CharsDistancesC.new()
    local self = {
        distances = {},
    }
    setmetatable(self, CharsDistancesC)

    task.defer(function()
        while true do
            task.wait(2)
            task.spawn(function()
                self:updateDistances()
            end)
        end
    end)

    return self
end

function CharsDistancesC:updateDistances()
    local playersData = {}
    self.distances = {}
    local idx = 1
    for _, plr in ipairs(Players:GetChildren()) do
        local char = plr.Character
        local isValid = char and char.Parent
        if not isValid then continue end
        local charParts = binderCharParts:getObj(char)
        if not charParts then continue end
        playersData[idx] = {
            plr,
            char,
            charParts.hrp
        }
        self.distances[char] = {
            array = {},
            charMap = {},
        }
        idx += 1
    end

    local numValidPlayers = #playersData
    for player_1_Idx = 1, numValidPlayers do
        if player_1_Idx == numValidPlayers then break end
        for player_2_Idx = player_1_Idx + 1, numValidPlayers do
            -- TableUtils.print(playersData)
            local distance = (playersData[player_1_Idx][3].Position - playersData[player_2_Idx][3].Position).Magnitude

            local plr1 = playersData[player_1_Idx][1]
            local plr2 = playersData[player_2_Idx][1]

            local char1 = playersData[player_1_Idx][2]
            local char2 = playersData[player_2_Idx][2]
            self.distances[char1]["charMap"][char2] = distance
            self.distances[char2]["charMap"][char1] = distance

            table.insert(self.distances[char1]["array"], {plr = plr2, char = char2, distance = distance})
            table.insert(self.distances[char2]["array"], {plr = plr1, char = char1, distance = distance})
        end
    end
    -- TableUtils.print(self.distances)
end

function CharsDistancesC:getCharsWithDistLTE(char, distThreshold, conditions)
    if not self.distances[char] then return end

    conditions = conditions or {}
    local firstCondition = function(targetCharData)
        if targetCharData.distance <= distThreshold then return true end
    end
    table.insert(conditions, 1, firstCondition)
    return Iterators.conditions(self.distances[char]["array"], conditions)

    -- return Functional.filter(self.distances[char]["array"], function(v)
    --     return v.distance <= distThreshold
    -- end)
end

function CharsDistancesC:areCharsNear(char1, char2, distance)
    if not self.distances[char1] then return end
    if not self.distances[char1]["charMap"][char2] then return end
    return self.distances[char1]["charMap"][char2] <= distance
end

function CharsDistancesC:Destroy()
    self._maid:Destroy()
end

SingletonsManager.addSingleton(CharsDistancesC.className, CharsDistancesC.new())

return CharsDistancesC