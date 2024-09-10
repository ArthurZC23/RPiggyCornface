-- Standard saving of data stores
-- The key you provide to DataStore2 is the name of the store with GetDataStore
-- GetAsync/UpdateAsync are then called based on the user ID
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Mod = require(ReplicatedStorage:WaitForChild("Sherlocks"):WaitForChild("Shared"):WaitForChild("Mod"))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local GameData = Data.Game.Game
local DsbConfig = Data.DataStore.DsbConfig
local TimeUnits = Data.Date.TimeUnits

local DataStoreService = require(ServerStorage.DataStoreService)
local Promise = Mod:find({"Promise", "Promise"})

local SessionLockingWarningRE = ReplicatedStorage.Remotes.Events.SessionLockingWarning

local Standard = {}
Standard.__index = Standard

local function fireSessionLockWarningRemote(player, isSessionLocked, ...)
    local p1 = Promise.fromEvent(SessionLockingWarningRE.OnServerEvent, function(plr)
        return player == plr
    end)
    local p2 = Promise.fromEvent(Players.PlayerRemoving)
    Promise.any({p1, p2})
    SessionLockingWarningRE:FireClient(player, isSessionLocked, ...)
end

local function isPreviousSessionStillValid(value)
    if not value then return false end
    if not value.Server then return false end

    return value.Server.lockId ~= game.JobId

    -- Will have lockId if passed the two tests above.
    -- local lockId = value.Server.lockId
    -- if not lockId then return false end

    -- Update add lockId to state
    -- It also add and remove timeout

    -- local lockTimeout = value.Server.lockTimeout
    -- if lockTimeout then
    --     local delta = lockTimeout - Cronos:getTime()
    --     return true, delta
    -- else
    --     return false
    -- end
end

local function IsLockSessionProbablyDead(value)
    if not (value.Datetime and value.Datetime.ls) then
        return true
    end
    local lastSaveTimestamp = DateTime.fromIsoDate(value.Datetime.ls).UnixTimestamp
    return (Cronos:getTime() - lastSaveTimestamp) >= DsbConfig.SessionLockTimeout
end

function Standard:Get()
    return Promise.try(function()
        local player = Players:GetPlayerByUserId(self.userId)
        if not player then error("Player Left.") end

        local value = self.dataStore:UpdateAsync(self.userId, function(val)
            -- value will have a lockId from this server or from a previous server. Will be empty in the first fetch. In that case lockId will come from default values.
            -- lockTimeout for previous servers can be added if it doens't exit, can be deleted if expired or kept intact if still valid.
            --print("1")
            if not val then return val end -- Lock timeout will be added in default
            --print("2")
            if not val.Server then return val end -- Lock timeout will be added in default

            --print("3")
            local lockId = val.Server.lockId
            if not lockId or lockId == "" then
                --print("4")
                val.Server.lockId = game.JobId
                return val
            end

            if IsLockSessionProbablyDead(val) then
                val.Server.lockTimeout = nil
                val.Server.lockId = game.JobId
            end
            return val

            -- local lockTimeout = val.Server.lockTimeout
            -- if lockTimeout then
            --     print("5")
            --     if lockTimeout > Cronos:getTime() then
            --         -- valid lock
            --         print("6")
            --         print(lockTimeout, Cronos:getTime(), Cronos:getTime() - lockTimeout)
            --         return val
            --     else
            --         -- expired lock
            --         print("7")
            --         val.Server.lockTimeout = nil
            --         val.Server.lockId = game.JobId
            --     end
            -- else
            --     print("8")
            --     -- initial countdown
            --     val.Server.lockTimeout = Cronos:getTime() + GameData.sessionLocking.timeoutDelta
            -- end
            -- return val
        end)

        if not player.Parent then error("Player Left.") end

        -- if value and value.Server then
        --     print("job ids: ", value.Server.lockId, game.JobId)
        -- end

        local isValid = isPreviousSessionStillValid(value)

        if isValid then
            -- print("9")
            -- warn("Previous Session Lock is valid")
            local lastSaveTimestamp = DateTime.fromIsoDate(value.Datetime.ls).UnixTimestamp
            local delta = lastSaveTimestamp + DsbConfig.SessionLockTimeout - Cronos:getTime()
            local isSessionLocked = true
            task.defer(fireSessionLockWarningRemote, player, isSessionLocked, delta / 60)
            task.wait(30)
            --print("Delta: ", delta / 60)
            player:Kick(
                ("Your data didn't finish saving in an older server. This could take up to %s minutes if DataStore are out if the older server crashed."):format(delta / 60))
            error("Session Lock Has Not Expired Yet.")
        end
        -- print("10")
        -- warn("Previous Session Lock is NOT valid")
        local isSessionLocked = false
        task.defer(fireSessionLockWarningRemote, player, isSessionLocked, 0)
        
        return value
    end)
end

function Standard:Set(value)
    value.Datetime.ls = DateTime.fromUnixTimestamp(Cronos:getTime()):ToIsoDate() --last save
    value.Server.ver = GameData.version

    return Promise.try(function()
        if (value.Server.lockId ~= game.JobId) and value.Server.lockId then
            error("This server doesn't has the current player session.")
        end

        local ok, err = pcall(function()
            self.dataStore:UpdateAsync(self.userId, function() return value end)
        end)

        if ok then
            return
        else
            error(err)
        end

    end)
end

function Standard.new(dataStore2)
    return setmetatable({
        dataStore = DataStoreService:GetDataStore(dataStore2.Name),
        userId = dataStore2.UserId,
    }, Standard)
end

return Standard