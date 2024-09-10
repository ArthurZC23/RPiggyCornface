local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local HideBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="HideBtn"})

local Controller = {}
Controller.__index = Controller
Controller.className = "HideController"
Controller.TAG_NAME = Controller.className

function Controller.new(charGuis)
    local self = {
        _maid = Maid.new(),
        charGuis = charGuis,
    }
    setmetatable(self, Controller)
    -- if not self:getFields() then return end
    -- self:handleHide()
    return self
end

local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
function Controller:handleHide()
    self._maid:Add(HideBtn.Activated:Connect(function()
        local HideCharRE = ComposedKey.getEvent(self.charGuis.char, "HideChar")
        if not HideCharRE then return end
        HideCharRE:FireServer()
    end))

    self._maid:Add2(ButtonsUx.addUx(HideBtn, {
        dilatation = {
            expandFactor = {
                X=1.1,
                Y=1.1,
            }
        }
    }))
end

function Controller:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharState", self.charGuis.char},
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

