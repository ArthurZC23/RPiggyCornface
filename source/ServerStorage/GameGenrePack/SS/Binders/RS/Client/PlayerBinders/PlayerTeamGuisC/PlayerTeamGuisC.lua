local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

local PlayerTeamGuisC = {}
PlayerTeamGuisC.__index = PlayerTeamGuisC
PlayerTeamGuisC.className = "PlayerTeamGuis"
PlayerTeamGuisC.TAG_NAME = PlayerTeamGuisC.className

function PlayerTeamGuisC.new(player)
    if localPlayer ~= player then return end
    local self = {
        player = player,
        _maid = Maid.new(),
        views = {},
    }
    setmetatable(self, PlayerTeamGuisC)

    if not self:getFields() then return end
    self:handleGuis()
    return self
end

function PlayerTeamGuisC:handleGuis()
    local function update(controller)
        local team = self.player:GetAttribute("team") or "human"
        local view = controller.view
        if not view then return end
        if not view.teamGui then return end
        if view.teamGui == team then
            view:open()
        else
            view:close()
        end
    end

    local function updateAll()
        for _, controller in pairs(self.playerGuis.controllers) do
            update(controller)
        end
    end

    self._maid:Add2(self.playerGuis.AddControllerSE:Connect(update))
    self._maid:Add2(self.player:GetAttributeChangedSignal("team"):Connect(updateAll))
    updateAll()
end

function PlayerTeamGuisC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
                {"PlayerGuis", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.PlayerGui = self.player:FindFirstChild("PlayerGui")
            if not self.PlayerGui then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=1
    })
    return ok
end

function PlayerTeamGuisC:Destroy()
    self._maid:Destroy()
end

return PlayerTeamGuisC