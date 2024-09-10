local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})

local FsmSyncer = {}
FsmSyncer.__index = FsmSyncer

function FsmSyncer.new(syncedInst, syncName)
    local self = {
        _maid = Maid.new(),
        syncedInst = syncedInst,
        syncName = syncName,
        syncEventName = ("FsmSync%s"):format(syncName),
        initialSyncFunctionName = ("FsmInitialSync%s"):format(syncName)
    }
	setmetatable(self, FsmSyncer)

    if not self:getFields() then return end

    return self
end

function FsmSyncer:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            do
                self[self.syncEventName] = ComposedKey.getFirstDescendant(self.syncedInst, {"Remotes", "Events", self.syncEventName})
                if not self[self.syncEventName] then return end
            end
            do
                self[self.initialSyncFunctionName] = ComposedKey.getFirstDescendant(self.syncedInst, {"Remotes", "Functions", self.initialSyncFunctionName})
                if not self[self.initialSyncFunctionName] then return end
            end

            return true
        end,
        keepTrying=function()
            return self.syncedInst.Parent
        end,
    })
    return ok
end

function FsmSyncer:handleSync(states)
    local function sync(payload)
        if self.stateProm then
            self.stateProm:cancel()
            self.stateProm = nil
        end
        local stateObj = states[payload.stateName]
        self.stateProm = stateObj[payload.methodName](stateObj, payload.kwargs)
        if self.stateProm then
            self._maid:Add(
                self.stateProm,
                "cancel"
            )
        end
    end
    self._maid:Add(self[self.syncEventName].OnClientEvent:Connect(sync))
    local payload = self[self.initialSyncFunctionName]:InvokeServer()
    if payload then
        sync(payload)
    end
end

function FsmSyncer:Destroy()
    self._maid:Destroy()
end

return FsmSyncer