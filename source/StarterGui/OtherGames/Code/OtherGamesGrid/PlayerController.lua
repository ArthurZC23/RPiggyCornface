local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local RootF = script:FindFirstAncestor("OtherGamesGrid")
local View = require(ComposedKey.getAsync(RootF, {"PlayerView"}))

local Controller = {}
Controller.__index = Controller
Controller.className = "OtherGamesGridController"

function Controller.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self.view = self._maid:Add(View.new(self))

    return self
end

function Controller:teleportToGame(btn, gameName)
    self._maid:Add(btn.Activated:Connect(function()
        self.TeleportToOtherGameRE:FireServer(gameName)
    end))
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                "TeleportToOtherGame",
            }
            local root = localPlayer
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function Controller:Destroy()
    self._maid:Destroy()
end

return Controller