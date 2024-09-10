local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local DeveloperProductButtonC = {}
DeveloperProductButtonC.__index = DeveloperProductButtonC
DeveloperProductButtonC.className = "DeveloperProductButton"
DeveloperProductButtonC.TAG_NAME = DeveloperProductButtonC.className

function DeveloperProductButtonC.new(RootGui)
    local self = {
        RootGui = RootGui,
        _maid = Maid.new(),
    }
    setmetatable(self, DeveloperProductButtonC)

    if not self:getFields() then return end
    self:handleButton()
    self:handleUx()

    return self
end

local S = Data.Strings.Strings
local TryDeveloperPurchaseRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "TryDeveloperPurchase"})
function DeveloperProductButtonC:handleButton()
    self._maid:Add(self.Button.Activated:Connect(function()
        TryDeveloperPurchaseRE:FireServer(self.RootGui:GetAttribute("devProduct"))
    end))
end

local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
function DeveloperProductButtonC:handleUx()
    self._maid:Add2(ButtonsUx.addUx(self.Button, {
        dilatation = {
            expandFactor = {
                X=1.1,
                Y=1.1,
            }
        }
    }))
end

function DeveloperProductButtonC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.Button = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootGui, refName="Button"})
            if not self.Button then return end

            return true
        end,
        keepTrying=function()
            return self.RootGui.Parent
        end,
    })
    return ok
end

function DeveloperProductButtonC:Destroy()
    self._maid:Destroy()
end

return DeveloperProductButtonC