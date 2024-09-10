local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local TpToStartC = {}
TpToStartC.__index = TpToStartC
TpToStartC.className = "TpToStart"
TpToStartC.TAG_NAME = TpToStartC.className

function TpToStartC.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, TpToStartC)

    if not self:getFields() then return end
    part.CanTouch = true
    self:handleTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function TpToStartC:handleTouch()
    self._maid:Add2(self.part.Touched:Connect(LocalDebounce.playerExecution(function(player, hit)
        local char = hit.Parent
        if not char then return end

        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        char:PivotTo(self.Respawn:GetPivot())
    end)))
end

function TpToStartC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.Respawn = ComposedKey.getFirstDescendant(self.part, {"Respawn"})
            if not self.Respawn then return end
            self.Respawn = self.Respawn.Value
            if not self.Respawn then return end

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

function TpToStartC:Destroy()
    self._maid:Destroy()
end

return TpToStartC