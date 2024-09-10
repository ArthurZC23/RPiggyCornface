local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharMapPuzzleC = {}
CharMapPuzzleC.__index = CharMapPuzzleC
CharMapPuzzleC.className = "CharMapPuzzle"
CharMapPuzzleC.TAG_NAME = CharMapPuzzleC.className

function CharMapPuzzleC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end
    if char:HasTag("PlayerMonster") then return end

    local self = {
        char = char,
        _maid = Maid.new(),
        keysTool = {},
    }
    setmetatable(self, CharMapPuzzleC)

    if not self:getFields() then return end
    self:handlePuzzleReset()

    return self
end

function CharMapPuzzleC:handlePuzzleReset()
    local lifeState = self.playerState:get(S.Session, "Lives")
    if lifeState.shouldSyncCache then return end
    for _, PuzzleFProto in ipairs(workspace.Map.Chapters["1"].Puzzles.Puzzles:GetChildren()) do
        local PuzzleF = ReplicatedStorage.Assets.Puzzles.Puzzles["Chapter1"][PuzzleFProto.Name]:Clone()
        for i, Model in ipairs(PuzzleF:GetChildren()) do
            local ModelProto = PuzzleFProto[Model.Name]
            Model:PivotTo(ModelProto:GetPivot())
        end
        PuzzleF.Parent = PuzzleFProto.Parent
        PuzzleFProto:Destroy()
    end
end

function CharMapPuzzleC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
                {"CharState", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=1
    })
    return ok
end

function CharMapPuzzleC:Destroy()
    self._maid:Destroy()
end

return CharMapPuzzleC