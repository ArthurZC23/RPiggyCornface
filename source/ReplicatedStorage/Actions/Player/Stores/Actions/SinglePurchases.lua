local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
--local Data = Mod:find({"Data", "Data"}) -- Cannot use Data in actions
--local StarterPackData = Data.SinglePurchases.StarterPack.StarterPack
local TableUtils = Mod:find({"Table", "Utils"})

local actions = {}

function actions.startSinglePurchase(state, action)
    state[tostring(action.id)] = {} -- Empty table is different from nil. It allows to add details in the future.
    state[tostring(action.id)].status = "1"
    return state
end

function actions.finishSinglePurchase(state, action)
    state[tostring(action.id)].status = "2"
    return state
end

function actions.addDetails(state, action)
    assert(action.details.status == nil, "status key is reserved.")
    TableUtils.complementUnrestrained(state[tostring(action.id)], action.details)
    return state
end

function actions.removeSinglePurchase(state, action)
    state[tostring(action.id)] = nil
    return state
end

return actions