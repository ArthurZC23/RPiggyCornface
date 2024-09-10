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

local RootF = script:FindFirstAncestor("Trails")
local View = require(ComposedKey.getAsync(RootF, {"PlayerView"}))

local Controller = {}
Controller.__index = Controller
Controller.className = "TrailsController"

function Controller.new(playerGuis)
    local self = {
        _maid = Maid.new(),
        playerGuis = playerGuis,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    self.view = self._maid:Add(View.new(self))

    return self
end

function Controller:equipTrail(btn, trailId)
    local maid = Maid.new()

    maid:Add(btn.Activated:Connect(function()
        local char = localPlayer.Character
        if not (char and char.Parent) then return end
        local EquipTrailRE = ComposedKey.getEvent(char, "EquipTrail")
        if not EquipTrailRE then return end
        EquipTrailRE:FireServer(trailId)
    end))

    return maid
end

function Controller:unequipTrail(btn, trailId)
    local maid = Maid.new()

    maid:Add(btn.Activated:Connect(function()
        local char = localPlayer.Character
        if not (char and char.Parent) then return end
        local EquipTrailRE = ComposedKey.getEvent(char, "EquipTrail")
        if not EquipTrailRE then return end
        EquipTrailRE:FireServer(trailId, {unequip=true})
    end))

    return maid
end

function Controller:buyGp(btn, gpId)
    local maid = Maid.new()

    maid:Add(btn.Activated:Connect(function()
        local PurchaseGpRE = ComposedKey.getEvent(ReplicatedStorage, "PurchaseGp")
        if not PurchaseGpRE then return end
        print("gpId", gpId)
        PurchaseGpRE:FireServer(gpId)
    end))

    return maid
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {}
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