local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Functional = Mod:find({"Functional"})

local module = {}

local relevantClientServices = {
    "Players",
    "ReplicatedFirst",
    "ReplicatedStorage",
    "Workspace", -- Char and tools
}

function module.filterMessageClient(message)
    local isServiceRelevant = Functional.reduce(
        Functional.map(relevantClientServices, function(service)
            return message:match(service)
        end),
        function(acc, v)
            return acc or v
        end,
        {
            acc0 = false
        }
    )
    if not isServiceRelevant then return end
    if message:match("invalid UTF%-8") then return end
	if message:match("PlayerModule") then return end
	if message:match("BubbleChat") then return end
	if message:match("ChatScript") then return end
    if message:match("ChatModules") then return end
    if message:match("CameraModule") then return end
    if message:match("loadChatInfoInternal") then return end
    if message:match("Failed to load sound") then return end
    if message:match("Cannot load the AnimationClipProvider Service") then return end
    if message:match("Binders.Client.Animate") then return end

    return message
end

function module.filterMessageServer(message)
    if typeof(message) == "number" then
        local traceback = debug.traceback(nil, 2)
        task.spawn(function()
            print(("Error on filterMessageServer. %s"):format(traceback))
        end)
        return message
    end
    if #message > 8192 then return end
    if message:match("invalid UTF%-8") then return end
    if message:match("Failed to load sound") then return end
    if message:match("MeshContentProvider") then return end

    return message
end

return module