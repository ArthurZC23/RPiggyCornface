local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local MultipliersData = Data.Hamilton.Multipliers
local BoostsData = Data.Boosts.Boosts

local module = {}

function module.unitMultipliers()
    local tbl = {}
    for name, _ in pairs(MultipliersData.names) do
        tbl[name] = 1
    end
    return tbl
end

function module.getDisableableBoosts()
    local tbl = {}
    for id, data in pairs(BoostsData.boosts) do
        if data.canToggle then
            tbl[id] = true
        end
    end
    return tbl
end

return module