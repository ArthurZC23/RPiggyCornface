local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local FailTeleportBlockC = {}
FailTeleportBlockC.__index = FailTeleportBlockC
FailTeleportBlockC.className = "FailTeleportBlock"
FailTeleportBlockC.TAG_NAME = FailTeleportBlockC.className

function FailTeleportBlockC.new(Block)
    local self = {
        Block = Block,
        _maid = Maid.new(),
    }
    setmetatable(self, FailTeleportBlockC)

    if not self:getFields() then return end
    Block.CanTouch = true
    self:handleTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function FailTeleportBlockC:handleTouch()
    self._maid:Add2(self.Block.Touched:Connect(LocalDebounce.playerExecution(function(player, hit)
        local parent = hit.Parent
        if not parent then return end

        local TeleportToWorldSE = SharedSherlock:find({"Bindable", "sync"}, {root = parent, signal = "TeleportToWorld"})
        if not TeleportToWorldSE then return end
        TeleportToWorldSE:Fire()
    end)))
end

function FailTeleportBlockC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.world = self.Block:GetAttribute("WorldId")
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.Block.Parent
        end,
    })
    return ok
end

function FailTeleportBlockC:Destroy()
    self._maid:Destroy()
end

return FailTeleportBlockC