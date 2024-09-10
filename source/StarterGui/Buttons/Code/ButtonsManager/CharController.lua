local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Maid = Mod:find({"Maid"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local ButtonsManagerF = script:FindFirstAncestor("ButtonsManager")
local ButtonsManager = require(ComposedKey.getAsync(ButtonsManagerF, {"ButtonsManager"}))
local View = require(ComposedKey.getAsync(ButtonsManagerF, {"CharView"}))

local localPlayer = Players.LocalPlayer

local Controller = {}
Controller.__index = Controller
Controller.className = "ButtonsManagerController"
Controller.TAG_NAME = Controller.className

function Controller.new(charGuis)
    local self = {
        _maid = Maid.new(),
        charGuis = charGuis,
        charState = charGuis.charState,
    }
    setmetatable(self, Controller)
    if not self:getFields() then return end
    local view = self._maid:AddComponent(View.new(self))
    if not view then return end
    self:handleButtonsManager()
    return self
end

function Controller:handleButtonsManager()
    self._maid:Add2(ButtonsManager.filterTeamButtons(self))
    self._maid:Add2(ButtonsManager.handleClose(self))
    self._maid:Add2(ButtonsManager.handleOpen(self))
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerGuis", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

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