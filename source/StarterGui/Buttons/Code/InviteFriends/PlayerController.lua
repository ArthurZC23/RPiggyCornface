local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local InviteFriendsFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="InviteFriendsFrame"})
-- local InviteFriendsFr2 = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="InviteFriendsFr2"})
-- local FriendBoost = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="FriendBoost"})

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "InviteFriendsController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerController)
    local self = {
        _maid = Maid.new(),
        playerController = playerController,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    -- self:handleBoost()
    self:handleInvite()
    return self
end

-- function Controller:handleBoost()
--     local function update(state)
--         local percentage = 100 * (state[S.Friends] - 1)
--         FriendBoost.Text = ("Friend Boost: +%.1f%%"):format(percentage)
--     end
--     self._maid:Add(self.playerState:getEvent(S.Session, "Multipliers", "updateMultiplier"):Connect(update))
--     local state = self.playerState:get(S.Session, "Multipliers")
--     update(state)
-- end

function Controller:handleInvite()
    for i, Btn in ipairs({
        InviteFriendsFrame.Open,
        -- InviteFriendsFr2.Btn
    }) do
        self._maid:Add2(Btn.Activated:Connect(function()
            local ok, canSend = pcall(function()
                return SocialService:CanSendGameInviteAsync(localPlayer)
            end)
            if ok and canSend then
                local inviteOptions = Instance.new("ExperienceInviteOptions")
                inviteOptions.PromptMessage = "Play with Friends!"
                SocialService:PromptGameInvite(localPlayer, inviteOptions)
            elseif not ok then
                warn(canSend)
            end
        end))
    end
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local char = localPlayer.Character
            if not (char and char.Parent) then return end
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller