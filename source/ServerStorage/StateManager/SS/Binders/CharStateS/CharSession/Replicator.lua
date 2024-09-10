local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Gaia = Mod:find({"Gaia", "Server"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})

local Replicator = {}
Replicator.__index = Replicator

Replicator.stateType = "Session"

function Replicator.new(stateType)
    local self = {
        stateType = stateType,
        _maid = Maid.new(),
        player = stateType.player,
        requestFunctionName = ("Request%s%sReplica"):format(stateType.stateManager.className, stateType.className),
    }
    setmetatable(self, Replicator)
    if not self:getFields() then return end
    self:createRemotes()
    self:replicate()
    return self
end

function Replicator:getFields()
    local char = self.stateType.stateManager.char
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local charId = char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end
            return true
        end,
        keepTrying=function()
            return char.Parent
        end,
    })
    return ok
end

function Replicator:createRemotes()
    self._maid:Add(Gaia.createBinderRemotes(self, self.charEvents, {
        functions={
            self.requestFunctionName
        },
    }))
end

function Replicator:replicate()
    local function _sendReplica(plr)
        -- print("[Replicator:replicate _sendReplica] 1")
        if plr ~= self.stateType.stateManager.player then return end
        -- print("[Replicator:replicate _sendReplica] 2")
        local replica = self.stateType.initialReplica
        self.stateType.initialReplica = nil
        -- print("[Replicator:replicate _sendReplica] 3")
        self.stateType.stateManager:updateReplicationConditions(Replicator.stateType)
        -- print("[Replicator:replicate _sendReplica] 4")
        -- print("[Replicator:replicate]", self[("%sRF"):format(self.requestFunctionName)]:GetFullName())
        return replica
    end
    self[("%sRF"):format(self.requestFunctionName)].OnServerInvoke = _sendReplica
end

function Replicator:sync(scope, action)
    self.stateType.stateManager.stateManagers:addFrame(
        self.stateType.stateManager.className, Replicator.stateType, scope, action)
end

function Replicator:Destroy()
    self._maid:Destroy()
end


return Replicator