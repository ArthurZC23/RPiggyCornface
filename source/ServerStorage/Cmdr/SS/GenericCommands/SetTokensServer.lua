local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Sampler = Mod:find({"Math", "Sampler"})

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local function sendNotification(player, numTokens)
    local texts
    local sampler = Sampler.new()
    local totalTokens = Data.Map.Map.numberTokens
    if numTokens < 0.3 * totalTokens then
        texts = {
            "Nice work",
            "Well done",
        }
    elseif numTokens < 0.6 * totalTokens then
        texts = {
            "Don't stop now",
            "Keep going",
        }
    elseif numTokens < totalTokens then
        texts = {
            "Just a few more",
            "Almost there",
        }
    else
        texts = {
            "Go back to the house",
        }
    end
    local Text = sampler:sampleArray(texts)
    NotificationStreamRE:FireClient(player,
        {
            Text = Text,
        },
        {
            Root = "Tokens",
            lifetime = 6,
        }
    )
end

return function (context, player, value)
    local playerState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "PlayerState", inst = player})
    if not playerState then return end
    do
        local action = {
            name = "reset",
        }
        playerState:set(S.Session, "MapTokens", action)
    end
    for i = 1, value do
        do
            local action = {
                name = "add",
                id = tostring(i),
                ux = true,
            }
            playerState:set(S.Session, "MapTokens", action)
        end
    end
    sendNotification(player, value)

	return true
end