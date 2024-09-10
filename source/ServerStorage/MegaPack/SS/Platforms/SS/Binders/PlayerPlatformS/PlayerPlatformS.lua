local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local Promise = Mod:find({"Promise", "Promise"})

local PlayerPlatformS = {}
PlayerPlatformS.__index = PlayerPlatformS
PlayerPlatformS.className = "PlayerPlatform"
PlayerPlatformS.TAG_NAME = PlayerPlatformS.className

function PlayerPlatformS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerPlatformS)
    if not self:getFields() then return end
    self:createRemotes()
    self:setPlatform()

    return self
end

function PlayerPlatformS:setPlatform()
    local promise = self._maid:Add2(Promise.fromEvent(self.GetPlayerPlatformRE.OnServerEvent, function(plr)
        return self.player == plr
    end)
    :andThen(function(plr, platform)
        self:_setPlatform(plr, platform)
    end)
    , "GetPlatform")
    self.GetPlayerPlatformRE:FireClient(self.player)

    local ok, err = promise:await()
    if not ok then
        warn(tostring(err))
    end
end

function PlayerPlatformS:getPlatform()
    return self.player:GetAttribute("Platform")
end

function PlayerPlatformS:_setPlatform(plr, platform)
    assert(self.player == plr)
    assert(Platforms[platform], ("Platform %s is not valid"):format(tostring(platform)))
    self.player:SetAttribute("Platform", platform)
end


function PlayerPlatformS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"GetPlayerPlatform"},
        functions = {},
    }))
end

function PlayerPlatformS:getFields()
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

function PlayerPlatformS:Destroy()
    self._maid:Destroy()
end

return PlayerPlatformS