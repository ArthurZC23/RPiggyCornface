local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local localPlayer = Players.LocalPlayer

local PlayerGuisC = {}
PlayerGuisC.__index = PlayerGuisC
PlayerGuisC.className = "PlayerGuis"
PlayerGuisC.TAG_NAME = PlayerGuisC.className

function PlayerGuisC.new(player)
    if localPlayer ~= player then return end
    local self = {
        player = player,
        _maid = Maid.new(),
        controllers = {},
        views = {},
    }
    setmetatable(self, PlayerGuisC)

    if not self:getFields() then return end
    self:createSignals()
    self:initGuis()
    return self
end

function PlayerGuisC:initGuis()
    local function init(gui)
        -- Respawn guis appear before this is destroyed.
        if self._maid.isDestroyed then return end
        -- print(("Load Gui %s"):format(gui:GetFullName()))
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("ModuleScript") and desc.Name == "RunPlayerGui" then
                task.spawn(function()
                    -- print(("Run %s"):format(desc:GetFullName()))
                    local mod = require(desc)
                    self._maid:Add(mod.run(self))
                    -- print(("Run Finished %s"):format(desc:GetFullName()))
                end)
            end
        end
    end

    self._maid:Add2(self.PlayerGui.ChildAdded:Connect(init), "InitGui")
    for _, gui in ipairs(self.PlayerGui:GetChildren()) do
        task.spawn(init, gui)
    end
end

function PlayerGuisC:addController(id, controller)
    if self.controllers[id] then
        error(("Gui Controller id %s is already taken by %s."):format(controller.className, self.controllers[id].className))
    end
    self.controllers[id] = controller
    self.AddControllerSE:Fire(controller)
end

function PlayerGuisC:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.player, {
        events = {"AddController"},
    }))
end

function PlayerGuisC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
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

function PlayerGuisC:Destroy()
    self._maid:Destroy()
end

return PlayerGuisC