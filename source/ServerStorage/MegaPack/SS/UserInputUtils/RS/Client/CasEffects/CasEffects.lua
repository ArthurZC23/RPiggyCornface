local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

local localPlayer = Players.LocalPlayer

local module = {}

module.effects = {}

function module.removeActionEffect(actionName, effectId)
    if not module.effects[actionName] then
        ErrorReport.report(
            localPlayer.UserId,
            ("CasEffects tried to remove Action %s Effect %s, despite having no effect."):format(actionName, effectId),
            "error"
        )
        return
    end
    module.effects[actionName][effectId] = nil
end

function module.removeAllActionEffects(actionName)
    if not module.effects[actionName] then
        ErrorReport.report(
            localPlayer.UserId,
            ("CasEffects tried to remove All Action %s Effects, despite having no effect."):format(actionName),
            "error"
        )
        return
    end
    module.effects[actionName] = {}
end

function module.addActionTable(contextAction)
    module.effects[contextAction] = module.effects[contextAction] or {}
end

function module.addActionEffect(actionName, effectId, callback)
    module.effects[actionName] = module.effects[actionName] or {}
    module.effects[actionName][effectId] = callback
end

function module.applyEffect(actionName, ...)
    module.effects[actionName] = module.effects[actionName] or {}
    for id, callback in pairs(module.effects[actionName]) do
        task.spawn(callback, actionName, ...)
    end
end

return module