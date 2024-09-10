local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Mts = Mod:find({"Table", "Mts"})
local SignalE = Mod:find({"Signal", "Event"})
local Queue = Mod:find({"DataStructures", "Queue"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local RootFolder = script.Parent

local PlayerState = {}
PlayerState.__index = PlayerState
PlayerState.className = "PlayerState"
PlayerState.TAG_NAME = PlayerState.className

PlayerState.StateTypes = Mts.makeEnum("PlayerStateTypes", {
    ["Session"]="Session",
    ["Stores"]="Stores"
})

local Components = {
    [PlayerState.StateTypes.Stores] = require(RootFolder.PlayerStores.PlayerStores),
    [PlayerState.StateTypes.Session] = require(RootFolder.PlayerSession.PlayerSession),
}

function PlayerState.new(player)
    assert(player:IsA("Player"), ("Instance %s must be a player"):format(player:GetFullName()))
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerState)

    self.stateReplicationConditions = {
        [PlayerState.StateTypes.Stores] = false,
        [PlayerState.StateTypes.Session] = false,
    }

    if not self:getFields() then return end

    self._stateTypes = {}
    if not BinderUtils.initComponents(self, Components, {
        accessTable = self._stateTypes,
    }) then return end

    self.afterSaveSignal = self._maid:Add(SignalE.new())

    self.saveScheduler = JobScheduler.new(
        function()
            self:saveData()
        end,
        "cooldown",
        {
            queueProps = {
                {},
                {
                    maxSize=1,
                    fullQueueHandler=Queue.FullQueueHandlers.DiscardNew,
                    queueType=Queue.QueueTypes.FirstLastIdxs,
                }
            },
            schedulerProps = {
                cooldownFunc = function() return 30 end
            }
        }
    )

    if not player.Parent then return end

    return self
end

function PlayerState:updateReplicationConditions(condition)
    self.stateReplicationConditions[condition] = true
    -- print("------------------- PlayerState")
    -- TableUtils.print(self.stateReplicationConditions)
    local canReplicate = true
    for _, boolVal in pairs(self.stateReplicationConditions) do
        canReplicate = canReplicate and boolVal
    end
    -- print("canReplicate: ", canReplicate)
    -- print("---------------")
    if canReplicate then self.stateManagers:updateReplicationConditions("PlayerState") end
end

function PlayerState:get(stateType, scope)
    return self._stateTypes[stateType]:get(scope)
end

function PlayerState:set(stateType, scope, action)
    local kwargs = self._stateTypes[stateType]:set(scope, action)
    return kwargs
end

function PlayerState:getStoresStateCopy()
    return self._stateTypes["Stores"]:getStoresStateCopy()
end


function PlayerState:isStateBackup()
    return self._stateTypes["Stores"]:isStateBackup()
end

function PlayerState:getEvent(stateType, scope, eventName)
    return self._stateTypes[stateType]:getEvent(scope, eventName)
end

function PlayerState:saveData()
    local result = self._stateTypes[PlayerState.StateTypes.Stores]:saveData()
    self.afterSaveSignal:Fire()
    return result
end




function PlayerState:pushToSaveScheduler()
    self.saveScheduler:pushJob({})
end


function PlayerState:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerStateManagers", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            self.stateManagers = self.playerStateManagers
            self.playerStateManagers = nil

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerState:Destroy()
    self.isDestroyed = true
    self._maid:Destroy()
end

return PlayerState