local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local RegionsData = Data.Regions.Regions

local module = {}

module.callbacks = {}


function module.callbacks.AddRegions(state, action, events)
    for regionName in pairs(action.regions) do
        -- print("Add region: ", regionName)
        do
            local eventsNames = RegionsData.addRegionsEvents[regionName]
            for evName, data in pairs(eventsNames) do
                -- print("Event fired: ", evName)
                for k, v in pairs(data) do
                    action[k] = v
                end
                events[evName]:Fire(state, action, regionName)
            end
        end
        do
            local eventsNames = RegionsData.regionsEvents[regionName]
            for evName in pairs(eventsNames) do
                -- print("Event fired: ", evName)
                events[evName]:Fire(state, action, regionName)
            end
        end
    end
end

function module.callbacks.RemoveRegions(state, action, events)
    for regionName in pairs(action.regions) do
       -- print("Remove region: ", regionName)
        do
            local eventsNames = RegionsData.removeRegionsEvents[regionName]
            for evName, data in pairs(eventsNames) do
                -- print("Event to fire: ", evName)
                for k, v in pairs(data) do
                    action[k] = v
                end
                events[evName]:Fire(state, action, regionName)
            end
        end
        do
            local eventsNames = RegionsData.regionsEvents[regionName]
            for evName in pairs(eventsNames) do
                -- print("Event to fire: ", evName)
                events[evName]:Fire(state, action, regionName)
            end
        end
    end
end

return module