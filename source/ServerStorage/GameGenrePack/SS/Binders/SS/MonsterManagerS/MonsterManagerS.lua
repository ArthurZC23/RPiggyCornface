local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})

local binderGameState = SharedSherlock:find({"Binders", "getBinder"}, {tag="GameState"})
local gameState = SharedSherlock:find({"Binders", "waitForGameToBind"}, {binder=binderGameState, inst=game})

local function setAttributes()

end
setAttributes()

local MonsterManager = {}
MonsterManager.__index = MonsterManager
MonsterManager.className = "MonsterManager"
MonsterManager.TAG_NAME = MonsterManager.className

function MonsterManager.new(Device)
    local self = {
        _maid = Maid.new(),
        Device = Device,
    }
    setmetatable(self, MonsterManager)

    if not self:getFields() then return end
    self:handleMonsterSpawn()

    return self
end

function MonsterManager:handleMonsterSpawn()
    local function setNpcMonster(state)
        local maid = self._maid:Add2(Maid.new(), "MonsterSpawn")
        if Data.Studio.Studio.noNpcMonster then return end 
        local Monster = maid:Add2(Data.MonsterSkins.MonsterSkins.idData[state.skinId].monsterModel:Clone())
        Monster:SetAttribute("charRunAnimationFactor", 1.5)
        Monster:SetAttribute("monsterId", "1")
        Monster:SetAttribute("NpcId", "1")
        Monster:SetAttribute("rigType", "R15")
        Monster:SetAttribute("CoreAnimations", "Monster")
        local Humanoid = Monster.Humanoid
        Humanoid.WalkSpeed = 0
        Monster:AddTag("Npc")
        Monster:AddTag("Monster")
        Monster:SetAttribute("canKill", false)
        Monster:PivotTo(self.MonsterSpawn:GetPivot())
        Monster.Parent = self.MonsterFolder

        maid:Add2(Promise.delay(3)
        :andThen(function()
            Humanoid.WalkSpeed = 16 - 0.5
            Monster:SetAttribute("canKill", true)
        end))
    end
    local function setPlayerMonster(state)
        local player = Players:GetPlayerByUserId(state.playerId)
        if not player then return end

        local maid = self._maid:Add2(Maid.new(), "MonsterSpawn")
        player:SetAttribute("team", "monster")
        maid:Add2(function()
            player:SetAttribute("team", "human")
        end)

    end
    self._maid:Add(gameState:getEvent(S.Session, "Monster", "setNpcMonster"):Connect(setNpcMonster))
    self._maid:Add(gameState:getEvent(S.Session, "Monster", "setPlayerMonster"):Connect(setPlayerMonster))
    local state = gameState:get(S.Session, "Monster")
    if state._type == "npc" then
        setNpcMonster(state)
    else
        setPlayerMonster(state)
    end
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MonsterManager:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local Chapter1 = workspace.Map.Chapters["1"]
            self.MonsterSpawn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=Chapter1, refName="MonsterSpawn"})
            if not self.MonsterSpawn then return end
            self.MonsterFolder = SharedSherlock:find({"EzRef", "GetSync"}, {inst=Chapter1, refName="MonsterFolder"})
            if not self.MonsterFolder then return end

            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.Device.Parent
        end,
        cooldown=nil
    })
end

function MonsterManager:Destroy()
    self._maid:Destroy()
end

return MonsterManager