local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local TpToTargetPartC = {}
TpToTargetPartC.__index = TpToTargetPartC
TpToTargetPartC.className = "TpToTargetPart"
TpToTargetPartC.TAG_NAME = TpToTargetPartC.className

function TpToTargetPartC.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, TpToTargetPartC)

    if not self:getFields() then return end
    part.CanTouch = true
    self:handleTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function TpToTargetPartC:handleTouch()
    self._maid:Add2(self.part.Touched:Connect(LocalDebounce.playerExecution(function(player, hit)
        local char = hit.Parent
        if not char then return end

        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        char:PivotTo(self.TpTarget:GetPivot())
    end)))
end

function TpToTargetPartC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.TpTarget = ComposedKey.getFirstDescendant(self.part, {"TpTarget"})
            if not self.TpTarget then return end
            self.TpTarget = self.TpTarget.Value
            if not self.TpTarget then return end

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

function TpToTargetPartC:Destroy()
    self._maid:Destroy()
end

return TpToTargetPartC