local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local localPlayer = Players.LocalPlayer

local function setAttributes()
    script:SetAttribute("VerticalStudsOffset", 0)
end
setAttributes()

local PlayerChatC = {}
PlayerChatC.__index = PlayerChatC
PlayerChatC.className = "PlayerChat"
PlayerChatC.TAG_NAME = PlayerChatC.className

function PlayerChatC.new(player)
    if player ~= localPlayer then return end

    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerChatC)

    if not self:getFields() then return end
    self:customizeChatMessage()

    return self
end

function PlayerChatC:customizeChatMessage()
    TextChatService.OnIncomingMessage = function(message)
        TextChatService.BubbleChatConfiguration.VerticalStudsOffset = script:GetAttribute("VerticalStudsOffset")
        local properties = Instance.new("TextChatMessageProperties")
        if message.TextSource then
            local player = Players:GetPlayerByUserId(message.TextSource.UserId)
            local tagText = player:GetAttribute("ChatTagText") or ""
            if tagText ~= "" then
                tagText = ("<font color='#F5CD30'>[%s]</font> "):format(tagText)
            else
                tagText = ""
            end
            if localPlayer == player then
                local TextSource = ComposedKey.getFirstDescendant(TextChatService, {"TextChannels", "RBXGeneral", self.player.Name})
                if TextSource and not (TextSource.CanSend) then
                    tagText = ("[muted]%s"):format(tagText)
                end
            end
            -- local tagColor = player:GetAttribute("ChatTagColor") or Data.Chat.Chat.chatTagDefault.tagColor
            -- local nameColor = player:GetAttribute("ChatNameColor") or Data.Chat.Chat.chatTagDefault.nameColor
            local msgColor = player:GetAttribute("ChatMessageColor") or Data.Chat.Chat.chatTagDefault.msgColor
            properties.PrefixText = tagText .. message.PrefixText
            -- properties.Text = ("<font color='#%s'>%s</font>"):format(msgColor, message.Text)
        end
        return properties
    end
end

function PlayerChatC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil,
    })
end

function PlayerChatC:Destroy()
    self._maid:Destroy()
end

return PlayerChatC