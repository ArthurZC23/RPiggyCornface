local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Giver = Mod:find({"Hamilton", "Giver", "Giver"})

local function _giveSink(pet, sink, sinkQty, kwargs)
    local current = pet:GetAttribute(sink)
    local newVal = math.max(current - sinkQty, 0)
    pet:SetAttribute(sink, newVal)
end

local function _gainSource(playerState, source, sourceQty, kwargs)
    local actionKeys = {
        ["noUx"] = true,
    }
    Giver.give(playerState, source, sourceQty, kwargs.sourceType, actionKeys)
end

local module = {}

function module.convertAll(playerState, pet, sink, source, sinkQty, sourceQty, kwargs)
    _giveSink(pet, sink, sinkQty, kwargs)
    _gainSource(playerState, source, sourceQty, kwargs)
end

return module