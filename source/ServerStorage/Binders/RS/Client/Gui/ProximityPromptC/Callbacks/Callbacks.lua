local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local Bindables = ReplicatedStorage.Bindables

local module = {}

-- Invite friends
module["1"] = function(kwargs)
    local ok, canSend = pcall(function()
        return SocialService:CanSendGameInviteAsync(localPlayer)
    end)

    print(ok, canSend)
    if ok and canSend then
        local inviteOptions = Instance.new("ExperienceInviteOptions")
        inviteOptions.PromptMessage = "Invite Friends for Game Boost!"
        SocialService:PromptGameInvite(localPlayer, inviteOptions)
    elseif not ok then
        warn(canSend)
    end
end

return module