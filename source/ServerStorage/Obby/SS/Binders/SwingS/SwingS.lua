local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local SwingS = {}
SwingS.__index = SwingS
SwingS.className = "Swing"
SwingS.TAG_NAME = SwingS.className

function SwingS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, SwingS)

    if not self:getFields() then return end
    self:handlwSwing()

    return self
end

local function setAttributes()
    script:SetAttribute("Impulse", 1e5)
end
setAttributes()

function SwingS:handlwSwing()
    local seat = self.RootModel.Seat
    -- doesn't work
    -- self._maid:Add2(seat:GetPropertyChangedSignal("Occupant"):Connect(function()
    --     if seat.Occupant then
    --         local char = seat.Occupant.Parent
    --         local hrp = char.HumanoidRootPart
    --         task.delay(2, function()
    --             print(script:GetAttribute("Impulse") * seat.CFrame.LookVector)
    --             hrp:ApplyImpulse(script:GetAttribute("Impulse") * seat.CFrame.LookVector)
    --         end)
    --     end
    -- end))
end

function SwingS:getFields()
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

function SwingS:Destroy()
    self._maid:Destroy()
end

return SwingS