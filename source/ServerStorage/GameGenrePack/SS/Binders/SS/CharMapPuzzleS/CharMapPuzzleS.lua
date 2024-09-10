local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharMapPuzzleS = {}
CharMapPuzzleS.__index = CharMapPuzzleS
CharMapPuzzleS.className = "CharMapPuzzle"
CharMapPuzzleS.TAG_NAME = CharMapPuzzleS.className

function CharMapPuzzleS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
        keysTool = {},
    }
    setmetatable(self, CharMapPuzzleS)

    if char:HasTag("PlayerMonster") then return end
    if not self:getFields() then return end
    self:createRemotes()
    self:setCacheBeforeDeath()
    self:syncPreviousLife()
    self:handleKeyStash()
    self:handleRemoveMapKey()

    return self
end

function CharMapPuzzleS:setCacheBeforeDeath()
    self._maid:Add(self.charHades.BeforeDeathSE:Connect(function()
        local mapPuzzleState = self.charState:get(S.Session, "MapPuzzles")
        do
            local action = {
                name = "setPreviousLifeCache",
                value = {
                    keySt = mapPuzzleState.keySt,
                },
            }
            self.playerState:set(S.Session, "Lives", action)
        end
    end))
end

function CharMapPuzzleS:handleRemoveMapKey()
    self._maid:Add2(self.RemoveMapKeyRE.OnServerEvent:Connect(function(plr, keyId)
        local char = plr.Character
        if not (char and char.Parent) then return end
        if char ~= self.char then return end
        local mapPuzzleState = self.charState:get(S.Session, "MapPuzzles")
        if not mapPuzzleState.keySt[keyId] then return end
        do
            local action = {
                name = "removeKey",
                id = keyId,
            }
            self.charState:set(S.Session, "MapPuzzles", action)
        end
    end))
end

function CharMapPuzzleS:handleKeyStash()
    local function resetKeys(_, action)
        for id, tool in pairs(self.keysTool) do
            tool:Destroy()
        end
        self.keysTool = {}
    end
    local function removeKey(_, action)
        local tool = self.keysTool[action.id]
        self.keysTool[action.id] = nil
        tool:Destroy()
    end
    local function addKey(_, action)
        local toolId = action.id
        local toolData = Data.Puzzles.Keys.idData[toolId]
        local tool = ReplicatedStorage.Assets.Puzzles.Keys.Tools[toolData.name]:Clone()
        self.keysTool[toolId] = tool
        tool.Name = toolData.prettyName
        local Backpack = ComposedKey.getFirstDescendant(self.player, {"Backpack"})
        tool.Parent = Backpack
    end

    self._maid:Add(self.charState:getEvent(S.Session, "MapPuzzles", "resetKeys"):Connect(resetKeys))
    self._maid:Add(self.charState:getEvent(S.Session, "MapPuzzles", "removeKey"):Connect(removeKey))
    self._maid:Add(self.charState:getEvent(S.Session, "MapPuzzles", "addKey"):Connect(addKey))
    local state = self.charState:get(S.Session, "MapPuzzles")
    for keyId in pairs(state.keySt) do
        addKey(nil, {id = keyId})
    end
end

function CharMapPuzzleS:syncPreviousLife()
    local lifeState = self.playerState:get(S.Session, "Lives")
    if not (lifeState.previousLifeCache and lifeState.shouldSyncCache) then return end
    for keyId in pairs(lifeState.previousLifeCache.keySt) do
        local action = {
            name = "addKey",
            id = keyId,
        }
        self.charState:set(S.Session, "MapPuzzles", action)
    end
end

function CharMapPuzzleS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"RemoveMapKey"},
        functions = {},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharMapPuzzleS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharState", self.char},
                {"CharHades", self.char},
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

function CharMapPuzzleS:Destroy()
    self._maid:Destroy()
end

return CharMapPuzzleS