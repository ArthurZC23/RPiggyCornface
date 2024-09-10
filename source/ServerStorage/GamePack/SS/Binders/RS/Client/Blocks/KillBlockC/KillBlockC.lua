local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local KillBlockC = {}
KillBlockC.__index = KillBlockC
KillBlockC.className = "KillBlock"
KillBlockC.TAG_NAME = KillBlockC.className

function KillBlockC.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, KillBlockC)

    if not self:getFields() then return end
    part.CanTouch = true
    self:handleTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function KillBlockC:handleTouch()
    self._maid:Add2(self.part.Touched:Connect(LocalDebounce.playerExecution(function(player, hit)
        local parent = hit.Parent
        if not parent then return end

        local humanoid = parent:FindFirstChild("Humanoid")
        if not humanoid then return end
        if humanoid.Health <= 0 then return end
        humanoid.Health = 0
    end)))
end

function KillBlockC:getFields()
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

function KillBlockC:Destroy()
    self._maid:Destroy()
end

return KillBlockC