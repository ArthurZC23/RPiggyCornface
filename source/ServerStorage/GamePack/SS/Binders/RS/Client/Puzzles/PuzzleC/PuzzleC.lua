local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer
local PlayerGui  = localPlayer:WaitForChild("PlayerGui")

local function setAttributes()

end
setAttributes()

local PuzzleC = {}
PuzzleC.__index = PuzzleC
PuzzleC.className = "Puzzle"
PuzzleC.TAG_NAME = PuzzleC.className
PuzzleC.bagArray = {}

function PuzzleC.new(RootModel)
    if not RootModel:IsDescendantOf(workspace) then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
        keys = {},
    }
    setmetatable(self, PuzzleC)

    if not self:getFields() then return end
    self:addPuzzleToBagArray()
    self:createSignals()
    self:addHints()

    return self
end

function PuzzleC:addPuzzleToBagArray()
    PuzzleC.bagArray[self.puzzleId] = PuzzleC.bagArray[self.puzzleId] or {}
    table.insert(PuzzleC.bagArray[self.puzzleId], self)
    self._maid:Add2(function()
        local idx = table.find(PuzzleC.bagArray[self.puzzleId], self)
        table.remove(PuzzleC.bagArray[self.puzzleId], idx)
    end)
end

function PuzzleC:addHints()
    for keyId in pairs(Data.Puzzles.Puzzles.idData[self.puzzleId].keys) do
        local keyData = Data.Puzzles.Keys.idData[keyId]
        local HintGui = self._maid:Add2(GaiaShared.clone(ReplicatedStorage.Assets.Guis.PuzzleHint, {
            Adornee = self.RootModel.Skeleton.Hints[keyData.name],
            MaxDistance = 32,
            Parent = PlayerGui,
        }), ("KeyHint_%s"):format(keyId))
        HintGui.Name = ("%s_%s"):format(HintGui.Name, keyData.name)

        local Vpf = HintGui.Balloon.Vpf
        Vpf.CameraAngles.Value = keyData.CameraAngles
        Vpf.CameraPosition.Value = keyData.CameraPosition
        Vpf.CameraPositionOffset.Value = keyData.CameraPositionOffset
        local Model = keyData.keySpawnModel:Clone()
        Model.Name = "Model"
        Model.Parent = Vpf
        CollectionService:AddTag(Vpf, "Vpf")
    end
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
local TableUtils = Mod:find({"Table", "Utils"})
function PuzzleC:handleTouch()
    for _, Toucher in ipairs(self.Touchers:GetChildren()) do
        self._maid:Add2(Toucher.Touched:Connect(LocalDebounce.playerHrpCooldown(
            function(player, char, hrp)
                local charState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharState", inst = char})
                if not charState then return end
    
                local keyId = self:getCharKey(charState, char)
                if not keyId then return end
                if self.keys[keyId] then return end
    
                if not Data.Puzzles.Puzzles.idData[self.puzzleId].keys[keyId] then return end
    
                self.keys[keyId] = true
    
                local RemoveMapKeyRE = ComposedKey.getEvent(char, "RemoveMapKey")
                if RemoveMapKeyRE then
                    RemoveMapKeyRE:FireServer(keyId)
                end
    
                for i, puzzleObj in ipairs(PuzzleC.bagArray[self.puzzleId]) do
                    puzzleObj.UsePuzzleKeySE:Fire(keyId)
                    puzzleObj._maid:Remove(("KeyHint_%s"):format(keyId))
                end
                if TableUtils.len(self.keys) == TableUtils.len(Data.Puzzles.Puzzles.idData[self.puzzleId].keys) then
                    for i, puzzleObj in ipairs(PuzzleC.bagArray[self.puzzleId]) do
                        puzzleObj.FinishPuzzleSE:Fire()
                        puzzleObj.RootModel:RemoveTag(PuzzleC.TAG_NAME)
                    end
                end
            end,
            0.1
        )))
    end
end

function PuzzleC:getCharKey(charState, char)
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local keyId = tool:GetAttribute("keyId")
    if not keyId then return end

    local mapPuzzlesState = charState:get(S.Session, "MapPuzzles")
    if not mapPuzzlesState.keySt[keyId] then return end

    return keyId
end

function PuzzleC:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.RootModel, {
        events = {"FinishPuzzle", "UsePuzzleKey"},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PuzzleC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.puzzleId = self.RootModel:GetAttribute("puzzleId")
            if not self.puzzleId then return end

            self.Touchers = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Touchers"})
            if not self.Touchers then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=nil
    })
end

function PuzzleC:Destroy()
    self._maid:Destroy()
end

return PuzzleC