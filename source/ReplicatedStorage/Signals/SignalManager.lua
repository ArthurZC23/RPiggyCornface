-- Easy way to get signals
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local module = {}
module.signals = {}

function module.add(Inst, signalName, signal)
    local maid = Maid.new()
    maid:Add(function()
        module.remove(Inst, signalName)
    end)
    module.signals[Inst] = module.signals[Inst] or {}
    module.signals[Inst][signalName] = signal
    return maid
end

function module.remove(Inst, signalName)
    module.signals[Inst][signalName] = nil
    if next(module.signals[Inst]) == nil then
        module.signals[Inst] = nil
    end
end

function module.get(Inst, signalName)
    local signals = module.signals[Inst]
    if not signals then return end
    return signals[signalName]
end

return module