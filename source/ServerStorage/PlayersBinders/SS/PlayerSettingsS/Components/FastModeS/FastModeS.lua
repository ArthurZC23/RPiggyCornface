local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local FastModeData = Data.Settings.FastMode

local FastModeS = {}
FastModeS.__index = FastModeS
FastModeS.className = "FastMode"
FastModeS.TAG_NAME = FastModeS.className

function FastModeS.new(playerSettings)
    local self = {
        _maid = Maid.new(),
        player = playerSettings.player,
    }
    setmetatable(self, FastModeS)
    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleFastModeRequest()

    return self
end

function FastModeS:handleFastModeRequest()
    self.network:Connect(self.SetFastModeRE.OnServerEvent, function(player, gameQuality)
        if not (gameQuality == FastModeData.nameToId.Fast or gameQuality == FastModeData.nameToId.Normal) then
            return
        end
        WaitFor.BObj(self.player, "PlayerState")
        :now()
        :andThen(function(playerState)
            local settingsState = playerState:get(S.Stores, "Settings")
            if settingsState.FastMode == gameQuality then return end

            local action = {
                name = "setFastMode",
                value = gameQuality,
            }
            playerState:set(S.Stores, "Settings", action)
        end)
    end)
end

function FastModeS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function FastModeS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"SetFastMode"},
        functions = {},
    }))
end

function FastModeS:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
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
    return ok
end

function FastModeS:Destroy()
    self._maid:Destroy()
end

return FastModeS