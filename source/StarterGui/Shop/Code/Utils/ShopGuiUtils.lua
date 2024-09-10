local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local module = {}

function module.purchaseGamePass(self, _gui, gpId)
    local maid = Maid.new()
    local btn = _gui.Btn
    maid:Add(btn.Activated:Connect(function()
        local PurchaseGpRE = ComposedKey.getFirstDescendant(ReplicatedStorage, {"Remotes", "Events", "PurchaseGp"})
        if not PurchaseGpRE then return end
        PurchaseGpRE:FireServer(gpId)
    end))
    return maid
end

return module