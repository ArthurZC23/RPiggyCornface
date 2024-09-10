local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})

local function _giveSink(playerState, sink, sinkQty, kwargs)
    -- This should be Expender.expend(playerState, sink, sinkQty, kwargs.sinkType)
    do
        local action = {
            name = "Decrement",
            value = sinkQty,
        }
        playerState:set("Stores", sink, action)
    end
end

local function _gainSource(playerState, source, sourceQty, kwargs)
    Giver.give(playerState, source, sourceQty, kwargs.sourceType, kwargs.actionKeys)
end

local module = {}

function module.convertAll(playerState, sink, source, sinkQty, sourceQty, kwargs)
    _giveSink(playerState, sink, sinkQty, kwargs)
    _gainSource(playerState, source, sourceQty, kwargs)
end

return module