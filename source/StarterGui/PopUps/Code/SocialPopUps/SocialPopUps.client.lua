local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})

local localPlayer = Players.LocalPlayer

if RunService:IsStudio() then return end

task.spawn(function()
    local duration = 10
    -- if RunService:IsStudio() then
    --     duration = 10
    -- end
    task.wait(duration)
    AvatarEditorService:PromptSetFavorite(Data.Game.Game.serverTypePlaceId.PRODUCTION, Enum.AvatarItemType.Asset, true)
end)


-- task.spawn(function()
--     local duration = 1 * 60
--     -- if RunService:IsStudio() then
--     --     duration = 7
--     -- end
--     task.wait(duration)

--     local ok, canSend = pcall(function()
--         return SocialService:CanSendGameInviteAsync(localPlayer)
--     end)

--     if ok and canSend then
--         local inviteOptions = Instance.new("ExperienceInviteOptions")
--         inviteOptions.PromptMessage = "Play with Friends!"
--         SocialService:PromptGameInvite(localPlayer, inviteOptions)
--     elseif not ok then
--         warn(canSend)
--     end
-- end)