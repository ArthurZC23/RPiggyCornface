local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local RootF = script:FindFirstAncestor("Respawn")
local View = require(ComposedKey.getAsync(RootF, {"PlayerView"}))

local Controller = {}
Controller.__index = Controller
Controller.className = "RespawnController"

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self.view = self._maid:Add(View.new(self))

    return self
end

function Controller:handlePurchaseLife(Btn)
    local maid = Maid.new()
    maid:Add2(Btn.Activated:Connect(function()
        local TryDeveloperPurchaseRE = ComposedKey.getEvent(ReplicatedStorage, "TryDeveloperPurchase")
        if not TryDeveloperPurchaseRE then return end
        TryDeveloperPurchaseRE:FireServer("1873873313")
    end))
    return maid
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            self.RespawnBtn = SharedSherlock:find({"EzRef", "GetSync"}, {inst=gui, refName="RespawnBtn"})
            if not self.RespawnBtn then return end

            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {

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