local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local InstanceDebounce = Mod:find({"Debounce", "InstanceDebounce"})

local S = Data.Strings.Strings

local KillDoorsS = {}
KillDoorsS.__index = KillDoorsS
KillDoorsS.className = "KillDoors"
KillDoorsS.TAG_NAME = KillDoorsS.className

function KillDoorsS.new(doors)
    local self = {
        doors = doors,
        _maid = Maid.new(),
    }
    setmetatable(self, KillDoorsS)

    if not self:getFields() then return end
    self:handleDoors()

    return self
end

function KillDoorsS:handleDoors()
    for _, doorsInRow in ipairs(self.doors:GetChildren()) do
        local doorsInRowChildren = doorsInRow:GetChildren()
        local safeIdx = Random.new():NextInteger(1, #doorsInRowChildren)
        for i, door in ipairs(doorsInRowChildren) do
            local Door = door.Door
            if safeIdx == i then
                Door.CanCollide = false
            else
                Door.CanCollide = false
                Door.CanTouch = true
                self._maid:Add2(Door.Touched:Connect(
                    InstanceDebounce.playerLimbCooldownPerPlayer(
                    function(player, char)
                        local humanoid = char:FindFirstChild("Humanoid")
                        if not humanoid then return end
                        if humanoid.Health <= 0 then return end
                        humanoid.Health = 0
                    end,
                    0.1,
                    "R6"
            )))
            end
        end
    end
end

function KillDoorsS:getFields()
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

function KillDoorsS:Destroy()
    self._maid:Destroy()
end

return KillDoorsS