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

local GamePassButtonC = {}
GamePassButtonC.__index = GamePassButtonC
GamePassButtonC.className = "GamePassButton"
GamePassButtonC.TAG_NAME = GamePassButtonC.className

function GamePassButtonC.new(RootGui)
    local self = {
        RootGui = RootGui,
        _maid = Maid.new(),
    }
    setmetatable(self, GamePassButtonC)

    if not self:getFields() then return end
    self:handleButton()
    self:handleUx()

    return self
end

local S = Data.Strings.Strings

function GamePassButtonC:handleButton()
    self._maid:Add(self.Button.Activated:Connect(function()
        local remote = ComposedKey.getEvent(ReplicatedStorage, "PurchaseGp")
        if not remote then return end
        local gamePass = self.RootGui:GetAttribute("gamePass")
        local gpId = Data.GamePasses.GamePasses.nameToData[gamePass].id
        remote:FireServer(gpId)
    end))
end

local ButtonsUx = require(ReplicatedStorage.Ux.Buttons)
function GamePassButtonC:handleUx()
    self._maid:Add2(ButtonsUx.addUx(self.Button, {
        dilatation = {
            expandFactor = {
                X=1.1,
                Y=1.1,
            }
        }
    }))
end

function GamePassButtonC:getFields()
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

function GamePassButtonC:Destroy()
    self._maid:Destroy()
end

return GamePassButtonC