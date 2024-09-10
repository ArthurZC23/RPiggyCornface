local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local ClientSherlock = Mod:find({"Sherlocks", "Client"})

local RootF = script.Parent
local View = require(RootF:WaitForChild("PlayerView"))

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local Buttons = ClientSherlock:find({"Gui"}, {gui=gui, refName="Buttons"})

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "TeleportToOtherGameController"
Controller.TAG_NAME = Controller.className

function Controller.new()
    local self = {
        _maid = Maid.new()
    }
    setmetatable(self, Controller)

    self.view = self._maid:Add(View.new(self))

    return self
end

function Controller:handleButtons(kwargs)
    local maid = Maid.new()
    local gameName = kwargs.gameName
    do
        local btn = Buttons.Teleport.Btn

        maid:Add(btn.Activated:Connect(function()
            local TeleportToOtherGameRE = ComposedKey.getEvent(localPlayer, "TeleportToOtherGame")
            if not TeleportToOtherGameRE then return end
            TeleportToOtherGameRE:FireServer(gameName)
            self.view:close()
        end))
    end
    do
        local btn = Buttons.Cancel.Btn
        maid:Add(btn.Activated:Connect(function()
            self.view:close()
        end))
    end
    return maid
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller