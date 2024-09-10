local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SingletonsManager = Mod:find({"Singleton", "Manager"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Promise = Mod:find({"Promise", "Promise"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local BigBen = Mod:find({"Cronos", "BigBen"})

local RootF = script.FindFirstAncestor("Network")
local RemotePacketSizeCounter = RootF:WaitForChild("RemotePacketSizeCounter")

local Network = {}
Network.__index = Network
Network.className = "Network"
Network.TAG_NAME = Network.className

function Network.new()
    local self = {
        _maid = Maid.new(),
        instCreation = {
            t0 = -math.huge,
            count = 0,
            instances = {},
        },
        isLogging = false,
    }
    setmetatable(self, Network)
    if not self:getFields() then return end

    return self
end

function Network:monitorInstCreations()
    local gameLoadingTime = 10
    Promise.delay(gameLoadingTime)
    :andThen(function()
        self._maid:Add(game.DescendantAdded:Connect(function(inst)
            self.instCreation.count += 1
            table.insert(self.instCreation.instances, inst:GetFullName())
            if self.instCreation.count > 100 then
                local instancesStr = table.concat(self.instCreation.instances, "\n")
                local msg = ("Instance creation spike.\n\nInstances: \n%s"):format(instancesStr)
                ErrorReport.report("", msg, "error")
                self.instCreation.count = 0
                self.instCreation.instances = {}
            end
        end))
        self._maid:Add(BigBen.every(2 * 60, "Heartbeat", "frame", false):Connect(function(_, timeStep)
            self.instCreation.count = 0
            self.instCreation.instances = {}
        end))
    end)
end

function Network:startLoggingInstCreations()
    local maid = self._maid:Add2(Maid.new(), "LoggingInstCreations")
    self.instCreation.instances = {}
    self.instCreation.count = 0
    maid:Add(game.DescendantAdded:Connect(function(inst)
        self.instCreation.count += 1
        table.insert(self.instCreation.instances, inst:GetFullName())
    end))
    maid:Add(function()
        local instancesStr = table.concat(self.instCreation.instances, "\n")
        local msg = ("Instances creation log:\n\n%s"):format(instancesStr)
        warn(msg)
        self.instCreation.count = 0
        self.instCreation.instances = {}
    end)
end

function Network:stopLoggingInstCreations()
    self._maid:Remove("LoggingInstCreations")
end

function Network:monitorEvent(event)
    local eventObj = setmetatable(
        {
        event = event,
        log = {
            FireServer = {
                totalSize = 0,
                calls = {},
            },
            OnClientEvent = {
                totalSize = 0,
                calls = {},
            },
        },
        },
        {
            __index = function(t, idx)
                return event[idx]
            end
        }
    )
    eventObj.FireServer = function(_, ...)
        if self.isLogging then
            local runContext
            if RunService:IsClient() then
                runContext = "Client"
            else
                runContext = "Server"
            end
            local size = RemotePacketSizeCounter.GetPacketSize({
                RunContext = runContext, -- Client or Server, remotes send different data based on context
                RemoteType = event.ClassName, -- RemoteFunctions have an additional size offset
                PacketData = {...} -- Array of remote packet data, supports most types
            })
            eventObj.log.FireServer.totalSize += size
            table.insert(eventObj.log.FireServer.calls, {
                size = size,
                t0 = os.clock(),
            })
        end
        event:FireServer(...)
    end


    eventObj.OnClientEvent = function()
        if not eventObj.firstClientHandler then
            eventObj.firstClientHandler = true
            local conn = event.OnClientEvent:Connect(function(...)
                if self.isLogging then
                    local runContext
                    if RunService:IsClient() then
                        runContext = "Client"
                    else
                        runContext = "Server"
                    end
                    local size = RemotePacketSizeCounter.GetPacketSize({
                        RunContext = runContext, -- Client or Server, remotes send different data based on context
                        RemoteType = event.ClassName, -- RemoteFunctions have an additional size offset
                        PacketData = {...} -- Array of remote packet data, supports most types
                    })
                    eventObj.log.OnClientEvent.totalSize += size
                    table.insert(eventObj.log.OnClientEvent.calls, {
                        size = size,
                        t0 = os.clock(),
                    })
                end
            end)
            local conn2
            conn2 = event.Destroying:Connect(function()
                conn:Destroy()
                conn = nil
                conn2:Destroy()
                conn2 = nil
            end)

            return event.OnClientEvent

        end
    end

    self.events[event] = eventObj
end

function Network:startLog()
    self.isLogging = true
    local maid = self._maid:Add2(Maid.new(), "NetworkLog")
    for _, desc in ipairs(game:GetDescendants()) do
        if not (desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction")) then continue end
        local ev = desc
        if RunService:IsClient() then
            maid:Add(ev.OnClientEvent:Connect(function(...)
                if self.isLogging then
                    local runContext = "Client"
                    local size = RemotePacketSizeCounter.GetPacketSize({
                        RunContext = runContext, -- Client or Server, remotes send different data based on context
                        RemoteType = ev.ClassName, -- RemoteFunctions have an additional size offset
                        PacketData = {...} -- Array of remote packet data, supports most types
                    })
                    eventObj.log.OnClientEvent.totalSize += size
                    table.insert(eventObj.log.OnClientEvent.calls, {
                        size = size,
                        t0 = os.clock(),
                    })
                end
            end))
        else
            maid:Add(ev.OnServerEvent:Connect(function(player, ...)
                
                if self.isLogging then
                    local runContext = "Server"
                    local size = RemotePacketSizeCounter.GetPacketSize({
                        RunContext = runContext, -- Client or Server, remotes send different data based on context
                        RemoteType = ev.ClassName, -- RemoteFunctions have an additional size offset
                        PacketData = {...} -- Array of remote packet data, supports most types
                    })
                    eventObj.log.OnClientEvent.totalSize += size
                    table.insert(eventObj.log.OnClientEvent.calls, {
                        size = size,
                        t0 = os.clock(),
                    })
                end
            end))
        end
    end
end

function Network:stopLog()
    self.isLogging = false
    self._maid:Remove("NetworkLog")
end

function Network:getRemoteLog(remote)

end

function Network:getAllLogs(remote)

end

function Network:getFields()
    return WaitFor.GetAsync({
        getter=function()
            return true
        end,
        keepTrying=function()
            return true
        end,
        cooldown=nil
    })
end

function Network:Destroy()
    self._maid:Destroy()
end

SingletonsManager.addSingleton(Network.className, Network.new())

return Network