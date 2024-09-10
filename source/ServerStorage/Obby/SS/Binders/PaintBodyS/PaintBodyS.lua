local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})

local PaintBlockS = {}
PaintBlockS.__index = PaintBlockS
PaintBlockS.className = "PaintBlock"
PaintBlockS.TAG_NAME = PaintBlockS.className

function PaintBlockS.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, PaintBlockS)

    if not self:getFields() then return end
    self:handle()

    return self
end

function PaintBlockS:handle()
    self._maid:Add2(self.part.Touched:Connect(InstanceDebounce.playerLimbCooldownPerPlayer(
        function(player, char)
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            local humanoidDescription = humanoid:GetAppliedDescription()
            local color = self.part.Color
            humanoidDescription.HeadColor = color
            humanoidDescription.LeftArmColor = color
            humanoidDescription.LeftLegColor = color
            humanoidDescription.RightArmColor = color
            humanoidDescription.RightLegColor = color
            humanoidDescription.TorsoColor = color
            humanoid:ApplyDescription(humanoidDescription)
        end,
        0.1,
        "R6"
    )))
end

function PaintBlockS:getFields()
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

function PaintBlockS:Destroy()
    self._maid:Destroy()
end

return PaintBlockS