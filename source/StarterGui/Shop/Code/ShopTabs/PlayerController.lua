local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local View = require(script.Parent:WaitForChild("PlayerView"))

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "ShopTabController"
Controller.TAG_NAME = Controller.className

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end

    self.view = self._maid:TryToAdd(View.new(self))
    if not self.view then return end

    return self
end

function Controller:handleTab(_gui, data)
    local maid = Maid.new()
    local btn = _gui.Btn
    maid:Add(btn.Activated:Connect(function()
        do
            local action = {
                name = "viewTab",
                tabName = data.name,
            }
            self.playerState:set(S.LocalSession, "ShopGui", action)
        end
    end))
    return maid
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
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
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
