local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local S = Data.Strings.Strings
local GaiaServer = Mod:find({"Gaia", "Server"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local PlayerChatS = {}
PlayerChatS.__index = PlayerChatS
PlayerChatS.className = "PlayerChat"
PlayerChatS.TAG_NAME = PlayerChatS.className

function PlayerChatS.new(player, kwargs)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerChatS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    -- self:handleVip()

    return self
end


-- function PlayerChatS:handleVip()
--     local gpsState = self.playerState:get(S.Stores, "GamePasses")
--     local vipGpId = Data.GamePasses.GamePasses.nameToData[S.VipGp].id
--     if not (gpsState[vipGpId]) then return end
--     self.player:SetAttribute("ChatTagText", "VIP")
-- end

function PlayerChatS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function PlayerChatS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"RequestChatTagChange", "ChangeColor"},
        functions = {},
    }))
end

function PlayerChatS:getFields()
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
        cooldown=nil
    })
end

function PlayerChatS:Destroy()
    self._maid:Destroy()
end

return PlayerChatS