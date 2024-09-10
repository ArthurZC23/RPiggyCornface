local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})
local Promise = Mod:find({"Promise", "Promise"})

local FakeBridgesS = {}
FakeBridgesS.__index = FakeBridgesS
FakeBridgesS.className = "FakeBridges"
FakeBridgesS.TAG_NAME = FakeBridgesS.className

function FakeBridgesS.new(bridges)
    local self = {
        bridges = bridges,
        _maid = Maid.new(),
    }
    setmetatable(self, FakeBridgesS)

    if not self:getFields() then return end
    self:handleBridges()

    return self
end

function FakeBridgesS:handleBridges()
    for _, bridgesInRow in ipairs(self.bridges:GetChildren()) do
        local bridgesInRowChildren = bridgesInRow:GetChildren()
        local safeIdx = Random.new():NextInteger(1, #bridgesInRowChildren)
        for i, bridge in ipairs(bridgesInRowChildren) do
            local Toucher = bridge.Toucher
            if safeIdx == i then
                Toucher.CanCollide = true
            else
                Toucher.CanCollide = true
                Toucher.CanTouch = true
                self._maid:Add2(Toucher.Touched:Connect(InstanceDebounce.playerLimbCooldownPerPlayer(
                    function(player, char)
                        if Toucher.CanCollide == false then return end
                        Toucher.CanCollide = false

                        self._maid:Add2(Promise.delay(2):andThen(function()
                            Toucher.CanCollide = true
                        end), ("RefreshBridge%s"):format(tostring(i)))
                    end,
                    0.1,
                    "R6"
            )))
            end
        end
    end
end

function FakeBridgesS:getFields()
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

function FakeBridgesS:Destroy()
    self._maid:Destroy()
end

return FakeBridgesS