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
        controllers = {},
        views = {},
    }
    setmetatable(self, PlayerTeamGuisC)

    if not self:getFields() then return end
    self:handleGuis()
    self:handleTeamChange()

    return self
end

function PlayerTeamGuisC:handleTeamChange()
    local function update()
        self._maid:Remove("Team")
        self.team = self.player:GetAttribute("team")
        self.teamMaid = self._maid:Add2(Maid.new(), "Team")
        self:addAllGuiControllers()
    end

    self._maid:Add2(self.player:GetAttributeChangedSignal("team"):Connect(update))
end

function PlayerTeamGuisC:addGuiControllers(gui)
        -- Respawn guis appear before this is destroyed.
        if self.teamMaid.isDestroyed then return end
        -- print(("Load Gui %s"):format(gui:GetFullName()))
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("ModuleScript") and desc.Name == ("PlayerControllerTeam%s"):format(self.team) then
                task.spawn(function()
                    local Controller = require(desc)
                    local conntroller = self.teamMaid:Add2(Controller.new(self))
                    self.teamMaid:Add2(self:addController(conntroller.className, conntroller))
                end)
            end
        end
end

function PlayerTeamGuisC:addAllGuiControllers()
    for _, gui in ipairs(self.PlayerGui:GetChildren()) do
        task.spawn(function()
            self:addGuiControllers(gui)
        end)
    end
end

function PlayerTeamGuisC:handleGuis()
    self.teamMaid = self._maid:Add2(Maid.new(), "Team")

    self._maid:Add2(self.PlayerGui.ChildAdded:Connect(function(gui)
        self:addGuiControllers(gui)
    end))
    self:addAllGuiControllers()
end

function PlayerTeamGuisC:addController(id, controller)
    local maid = Maid.new()

    if self.controllers[id] then
        error(("Gui Controller id %s is already taken by %s."):format(id, self.controllers[id].className))
    end

    maid:Add2(function()
        self.controllers[id] = nil
        self.playerGuis.controllers[id] = nil
    end)
    self.controllers[id] = controller
    self.playerGuis.controllers[id] = controller


    return maid
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

            self.team = self.player:GetAttribute("team")
            if not self.team then return end

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