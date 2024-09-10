local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local View = require(script.Parent:WaitForChild("PlayerView"))

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local ExitButton = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="ExitButton"}):WaitForChild("Exit")

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "BecomeMonsterTabsController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end

    self:handleButtonExits()
    self.view = self._maid:TryToAdd(View.new(self))
    if not self.view then return end

    return self
end

function Controller:handleButtonExits()
    self._maid:Add(ExitButton.Activated:Connect(function()
        local view = self.playerGuis.controllers["BecomeMonsterTabsController"].view
        view:close()
    end))
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function Controller:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return localPlayer.Parent
        end,
        cooldown=nil
    })
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller
