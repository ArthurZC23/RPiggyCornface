local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PromiseUtils = Mod:find({"Promise", "Utils"})

local promiseGenerator = PromiseUtils.retryGenerator(100, 30)

local module = {}

module["Leaderboards"] = function(dssTable, userId)
    for key, ds in pairs(dssTable) do
        promiseGenerator(function()
            local value = ds:RemoveAsync(userId)
            print(("Value stored in Leaderboard %s: "):format(key), value)
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :await()
    end
end

module[S.PurchaseHistory] = function(dssTable, userId, playerData)
    local lastIdx
    if playerData then
        lastIdx = playerData.DevPurchases.newestIdx
    else
        lastIdx = 1
    end
    for idx=1,lastIdx do
        local key = ("%s/%s"):format(userId, idx)
        promiseGenerator(function()
            dssTable["Newest"]:RemoveAsync(key)
            print(("Remove purchase with idx %s"):format(idx))
            Cronos.wait(1)
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :await()
    end
end

module["Backup"] = function(ds, userId)
    -- Key is userId/purchaseId
    local metaKey = ("%s/%s"):format(userId, "last")
    local metadata = ds:GetAsync(metaKey)
    if not metadata then return end

    for idx=1,metadata.idx + 60 do -- +60 cost 1 min and guarantees there is no skip
        promiseGenerator(function()
            local key = ("%s/%s"):format(userId, idx)
            ds:RemoveAsync(key)
            Cronos.wait(1)
            print(("Removed backup %s"):format(idx))
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :await()
    end

    do
        promiseGenerator(function()
            local key = ("%s/%s"):format(userId, "last")
            ds:RemoveAsync(key)
            print("Removed backup metadata")
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :await()
    end
end

module["Trades"] = function(ds, userId)
    do
        promiseGenerator(function()
            local key = ("%s/Uncommitted"):format(userId)
            local value = ds:RemoveAsync(key)
            print("Value stored in Trades ", value)
        end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :await()
    end
end

module["DATA"] = function(ds, userId)
    promiseGenerator(function()
        local value = ds:RemoveAsync(userId)
        print("Value stored in DATA: ", value)
    end)
    :catch(function (err)
        warn(tostring(err))
    end)
    :await()
end

return module