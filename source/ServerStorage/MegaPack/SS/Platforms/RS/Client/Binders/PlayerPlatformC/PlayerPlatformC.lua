local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local localPlayer = Players.LocalPlayer

local PlayerPlatformC = {}
PlayerPlatformC.__index = PlayerPlatformC
PlayerPlatformC.className = "PlayerPlatform"
PlayerPlatformC.TAG_NAME = PlayerPlatformC.className

function PlayerPlatformC.new(player)
    if player ~= localPlayer then return end
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerPlatformC)
    if not self:getFields() then return end
    self:setPlatform()
    self:handleRemote()

    return self
end

function PlayerPlatformC:handleRemote()
    self._maid:Add(self.GetPlayerPlatformRE.OnClientEvent:Connect(function()
        local platform = Platforms.getPlatform()
        self.GetPlayerPlatformRE:FireServer(platform)
    end))
end

function PlayerPlatformC:setPlatform()
    local platform = Platforms.getPlatform()
    self.player:SetAttribute("Platform", platform)
end

function PlayerPlatformC:getPlatform()
    return self.player:GetAttribute("Platform")
end

function PlayerPlatformC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                "GetPlayerPlatform",
            }
            local root = self.player
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerPlatformC:Destroy()
    self._maid:Destroy()
end

return PlayerPlatformC