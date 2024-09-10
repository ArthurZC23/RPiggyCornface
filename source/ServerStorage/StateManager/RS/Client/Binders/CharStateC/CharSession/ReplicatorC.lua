local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})

local ActionsLoader = Mod:find({"StateManager", "Actions", "Loader"})
local Actions = ActionsLoader.load(ReplicatedStorage.Actions.Char.Session.Actions)

local localPlayer = Players.LocalPlayer

local ReplicatorC = {}
ReplicatorC.__index = ReplicatorC
ReplicatorC.className = "CharSession"

function ReplicatorC.new(stateType)
    local self = {
        stateType = stateType,
        requestFunctionName = ("Request%s%sReplica"):format(stateType.stateManager.className, stateType.className),
        actionsQueue = {},
    }
    setmetatable(self, ReplicatorC)
    -- print("[ReplicatorC] 1")
    if not self:getFields() then return end
    -- print("[ReplicatorC] 2")

    return self
end

function ReplicatorC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            -- print("[ReplicatorC] getF 1")
            local charId = self.stateType.stateManager.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            local RFs = ComposedKey.getFirstDescendant(self.charEvents, {"Remotes", "Functions"})
            if not RFs then return end
            -- print("[ReplicatorC] getF 2")
            self.RequestReplicaRF = ComposedKey.getFirstDescendant(RFs, {self.requestFunctionName})
            if not self.RequestReplicaRF then return false end
            -- print("[ReplicatorC] getF 3")
            return true
        end,
        keepTrying=function()
            -- print("[ReplicatorC] getF 4")
            -- print(self.stateType.stateManager.char:GetFullName())
           return self.stateType.stateManager.char.Parent
        end,
    })
    return ok
end

function ReplicatorC:getReplica()
    -- print("[ReplicatorC:getReplica] 1")
    -- warn("PROBLEM HERE") -- Fixed with #470
    -- print("[ReplicatorC:getReplica]", self.RequestReplicaRF:GetFullName())
    local replica = self.RequestReplicaRF:InvokeServer()
    -- print("[ReplicatorC:getReplica] 2")
    self._isStateLoaded = true
    for _, data in ipairs(self.actionsQueue) do
        self:_sync(unpack(data))
    end
    -- print("[ReplicatorC:getReplica] 3")
    self.actionsQueue = nil
    return replica
end

function ReplicatorC:sync(scope, action)
    if self._isStateLoaded then
        self.stateType:set(scope, action)
    else
        table.insert(self.actionsQueue, {scope, action})
    end
end

function ReplicatorC:Destroy()

end


return ReplicatorC