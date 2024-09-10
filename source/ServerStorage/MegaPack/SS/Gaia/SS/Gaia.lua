local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--local TmpF = (ReplicatedStorage:WaitForChild("Gaia"):WaitForChild("Tmp"))

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaShared = Mod:find({"Gaia", "Shared"})

local RequestInstHandlers = require(ServerStorage.Hooks.Gaia.RequestInstHandlers)

local RFunctions = ReplicatedStorage.Remotes.Functions
local RequestInstanceRF = RFunctions:WaitForChild("GaiaRequestInstance")
--local DeleteTmpInstanceRF = RFunctions:WaitForChild("GaiaDeleteTmpInstance")

local Gaia = {}

-- local function deleteTmpInstance(_, id)
--     TmpF[id]:Destroy()
-- end
-- DeleteTmpInstanceRF.OnServerInvoke = deleteTmpInstance

local function getInstance(player, instId, kwargs)
    local handler = RequestInstHandlers[instId]
    if handler then
        local PlayerGui = player:WaitForChild("PlayerGui")
        local inst = handler(player, kwargs)
        inst.Parent = PlayerGui
        return true
    end
end
RequestInstanceRF.OnServerInvoke = getInstance

function Gaia.createRemotes(root, signals)

    local events = signals.events or {}
    local functions = signals.functions or {}

    local Remotes = root:FindFirstChild("Remotes") or GaiaShared.create("Folder", {
        Name="Remotes",
    })

    local RemoteEvents = Remotes:FindFirstChild("Events") or GaiaShared.create("Folder", {
        Name="Events",
        Parent=Remotes
    })

    local RemoteFunctions = Remotes:FindFirstChild("Functions") or GaiaShared.create("Folder", {
        Name="Functions",
        Parent=Remotes
    })

    local remotes = {}
    for _, name in ipairs(events) do
        if RemoteEvents:FindFirstChild(name) then
            error(("RemoteEvent %s was already created for root %s"):format(name, root:GetFullName()))
        end
        table.insert(remotes, GaiaShared.create("RemoteEvent", {Name=name, Parent=RemoteEvents}))
    end

    for _, name in ipairs(functions) do
        if RemoteFunctions:FindFirstChild(name) then
            error(("RemoteFunction %s was already created for root %s"):format(name, root:GetFullName()))
        end
        table.insert(remotes, GaiaShared.create("RemoteFunction", {Name=name, Parent=RemoteFunctions}))
    end

    Remotes.Parent = root

    return function()
        for _, remote in ipairs(remotes) do
            remote:Destroy()
        end
    end
end

function Gaia.createBinderRemotes(obj, root, signals)
    signals.events = signals.events or {}
    signals.functions = signals.functions or {}
    Gaia.createRemotes(root, {
        events = signals.events,
        functions = signals.functions,
    })
    for _, eventName in ipairs(signals.events) do
        obj[("%sRE"):format(eventName)] = root.Remotes.Events[eventName]
    end
    for _, funcName in ipairs(signals.functions) do
        obj[("%sRF"):format(funcName)] = root.Remotes.Functions[funcName]
    end
    return function()
        for _, eventName in ipairs(signals.events) do
            obj[("%sRE"):format(eventName)]:Destroy()
        end
        for _, funcName in ipairs(signals.functions) do
            obj[("%sRF"):format(funcName)]:Destroy()
        end
    end
end

return Gaia