local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local NotificationStreamSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="NotificationStream"})

local RootF = script:FindFirstAncestor("PlayerSettingsC")
local Components = {
    -- FastMode = require(ComposedKey.getAsync(RootF, {"Components", "FastModeC", "FastModeC"})),
}

local localPlayer = Players.LocalPlayer

local PlayerSettingsC = {}
PlayerSettingsC.__index = PlayerSettingsC
PlayerSettingsC.className = "PlayerSettings"
PlayerSettingsC.TAG_NAME = PlayerSettingsC.className

function PlayerSettingsC.new(player)
    if player ~= localPlayer then return end
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerSettingsC)

    if not self:getFields() then return end
    if not BinderUtils.initComponents(self, Components) then return end
    -- task.defer(function()
    --     self:debugPlatform()
    -- end)

    return self
end

function PlayerSettingsC:debugPlatform()
    local ServerTypesData = Data.Game.ServerTypes
    local envs = {
        [ServerTypesData.sTypes.StudioNotPublished] = true,
        [ServerTypesData.sTypes.StudioPublishedPrivate] = true,
        [ServerTypesData.sTypes.StudioPublishedTest] = true,
        [ServerTypesData.sTypes.StudioPublishedProduction] = true,
        [ServerTypesData.sTypes.LivePrivate] = true,
    }
    -- print("ServerType", ServerTypesData.ServerType, envs[ServerTypesData.ServerType])
    if envs[ServerTypesData.ServerType] then
        task.spawn(function()
            while true do
                task.wait(5)
                NotificationStreamSE:Fire({
                    Text = ("Platform: %s\n%s %s"):format(Platforms:getPlatform(), tostring(UserInputService.TouchEnabled), tostring(UserInputService.MouseEnabled)),
                })
            end
        end)
    end
end

function PlayerSettingsC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {

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

function PlayerSettingsC:Destroy()
    self._maid:Destroy()
end

return PlayerSettingsC