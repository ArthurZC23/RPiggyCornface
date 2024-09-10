local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})

local SpeedBlockS = {}
SpeedBlockS.__index = SpeedBlockS
SpeedBlockS.className = "SpeedBlock"
SpeedBlockS.TAG_NAME = SpeedBlockS.className

function SpeedBlockS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, SpeedBlockS)

    if not self:getFields() then return end
    self:handleTouch()
    self:handleGui()

    return self
end

function SpeedBlockS:handleTouch()
    local Toucher = self.RootModel.Toucher
    self._maid:Add2(Toucher.Touched:Connect(InstanceDebounce.playerLimbCooldownPerPlayer(
        function(player, char)
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            humanoid.WalkSpeed = self.RootModel:GetAttribute("Speed")
        end,
        0.1,
        "R6"
    )))
end

function SpeedBlockS:handleGui()
    local TextLabel = self.RootModel.BackPart.BillboardGui.TextLabel
    local speed = self.RootModel:GetAttribute("Speed")
    if speed ~= 16 then
        TextLabel.Text = ("Speed %s"):format(self.RootModel:GetAttribute("Speed"))
    else
        TextLabel.Text = ("Normal Speed"):format(self.RootModel:GetAttribute("Speed"))
    end
end

function SpeedBlockS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.part.Parent
        end,
    })
    return ok
end

function SpeedBlockS:Destroy()
    self._maid:Destroy()
end

return SpeedBlockS