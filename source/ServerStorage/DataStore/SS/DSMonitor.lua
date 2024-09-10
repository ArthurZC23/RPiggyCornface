local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local DataStoreService = require(ServerStorage.DataStoreService)

local BigNotificationGuiRE = ReplicatedStorage.Remotes.Events:WaitForChild("BigNotificationGui")

local PingDataStore = DataStoreService:GetDataStore("Ping")
local TIME_THRESHOLD = 10
local lastCheckTime
local datastoreWorking

local random = Random.new()

local function check()
    local success, err = pcall(function()
        --ping
        PingDataStore:SetAsync(
            string.char(random:NextInteger(65, 90)), -- A-Z in ASCII
            ""
        )
    end)
    if success then return true end
    local errMsg = ("Datastore Ping test failed. %s"):format(err)
    ErrorReport.report("Server", errMsg, "error")
    return false
end

local module = {}

function module.checkIfDSSIsWorking(func)
    return function(...)
        local currentTime = Cronos:getTime()
        if currentTime - lastCheckTime > TIME_THRESHOLD then
            datastoreWorking = check()
            lastCheckTime = currentTime
        end
        if datastoreWorking then
            func(...)
        else
            -- Check this
            local args = {...}
            local player = args[1]
            local notification = "DataStoreService is not working right now. Your purchase cannot be completed."
            BigNotificationGuiRE:FireClient(player, notification, 10)
        end
    end
end

function module.checkIfStateIsBackup(func)
    return function(player, productId)
        local binder = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
        local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binder, inst=player})
        if not playerState then return end
        local isBackup = playerState:isStateBackup()
        if isBackup then
            local notification = "You cannot buy products because Roblox didn't load your data. Rejoin to try again."
            BigNotificationGuiRE:FireClient(player, notification, 10)
        else
            func(player, productId)
        end
    end
end

lastCheckTime = Cronos:getTime()
datastoreWorking = check()

return module