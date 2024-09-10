local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Debounce = Mod:find({"Debounce", "Debounce"})
local Data = Mod:find({"Data", "Data"})
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local S = Data.Strings.Strings
local Queue = Mod:find({"DataStructures", "Queue"})

local PlayerNetwork = {}
PlayerNetwork.__index = PlayerNetwork
PlayerNetwork.className = "PlayerNetwork"
function PlayerNetwork.new(player)
    assert(player and player:IsA("Player"))
    local self = {
        _maid = Maid.new(),
        player = player,
        hofs = {},
    }
    setmetatable(self, PlayerNetwork)

    return self
end

function PlayerNetwork:netowrkLogger(params)

end

function PlayerNetwork:addDebounce(params)
    local debounceType = params.debounceType or "playerExclusiveRemote"
    local hof = function(cb)
        return Debounce[debounceType](cb, unpack(params.args))
    end
    table.insert(self.hofs, hof)
end

function PlayerNetwork:addJobSchedule(params)
    local hof = function(cb)
        local _cb = cb
        local scheduler = JobScheduler.new(
            _cb,
            params.schedulerType,
            params.kwargs
        )
        return function()
            scheduler:pushJob({})
        end
    end
    table.insert(self.hofs, hof)
end

function PlayerNetwork:addJobSKeepSomeWithCd(kwargs)
    self:AddJobSchedule({
        schedulerType = "cooldown",
        kwargs = {
            queueProps = {
                {},
                {
                    maxSize=kwargs.maxSize,
                    fullQueueHandler=Queue.FullQueueHandlers.ReplaceOld,
                    queueType=Queue.QueueTypes.FirstLastIdxs,
                }
            },
            schedulerProps = {
                cooldownFunc = function() return kwargs.cd end
            }
        },
    })
end

function PlayerNetwork:Connect(event, cb)
    for _, hof in ipairs(self.hofs) do
        cb = hof(cb)
    end
    local playerHof = function(func)
        return function(player, ...)
            if player ~= self.player then return end
            func(player, ...)
        end
    end
    cb = playerHof(cb)
    self._maid:Add(event:Connect(function(...)
        cb(...)
    end))
end

function PlayerNetwork:Destroy()
    self._maid:Destroy()
end

return PlayerNetwork