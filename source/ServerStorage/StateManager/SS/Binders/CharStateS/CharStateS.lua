local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Mts = Mod:find({"Table", "Mts"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)

local binderCharStateManagers = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharStateManagers"})

local CharStateS = {}
CharStateS.__index = CharStateS
CharStateS.className = "CharState"
CharStateS.TAG_NAME = CharStateS.className

CharStateS.StateTypes = Mts.makeEnum("CharStateTypes", {
    ["Session"]="Session",
})
local RootFolder = script.Parent
local StateTypesComponents = {
    [CharStateS.StateTypes.Session] = require(RootFolder.CharSession.CharSession)
}

function CharStateS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
        _stateTypes = {},
        stateReplicationConditions = {
            [CharStateS.StateTypes.Session] = false,
        },
    }
    setmetatable(self, CharStateS)
    if not self:getFields() then return end
    if not self:initStateTypes(char) then return end

    return self
end

function CharStateS:initStateTypes(char)
    for name, class in pairs(StateTypesComponents) do
        local obj = class.new(self)
        if obj then
            self._stateTypes[name] = self._maid:Add(obj)
        else
            return false
        end
    end
    return true
end

local BinderUtils = Mod:find({"Binder", "Utils"})
function CharStateS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end
            self.stateManagers = binderCharStateManagers:getObj(self.char)
            if not self.stateManagers then return end
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharStateS:updateReplicationConditions(condition)
    self.stateReplicationConditions[condition] = true
    -- print("------------------- CharStateS")
    -- TableUtils.print(self.stateReplicationConditions)
    local canReplicate = true
    for _, boolVal in pairs(self.stateReplicationConditions) do
        canReplicate = canReplicate and boolVal
    end
    -- print("canReplicate: ", canReplicate)
    -- print("---------------")
    if canReplicate then self.stateManagers:updateReplicationConditions("CharState") end
end

function CharStateS:get(stateType, scope)
    return self._stateTypes[stateType]:get(scope)
end

function CharStateS:set(stateType, scope, action)
    local kwargs = self._stateTypes[stateType]:set(scope, action)
    return kwargs
end

function CharStateS:getEvent(stateType, scope, eventName)
    return self._stateTypes[stateType]:getEvent(scope, eventName)
end

function CharStateS:Destroy()
    self.isDestroyed = true
    self._maid:Destroy()
end

return CharStateS