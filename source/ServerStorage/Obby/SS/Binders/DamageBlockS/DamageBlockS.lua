local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Functional = Mod:find({"Functional"})

local S = Data.Strings.Strings

local overlapParams = OverlapParams.new()
overlapParams.MaxParts = 0
overlapParams.FilterDescendantsInstances = {workspace.PlayersCharacters}
overlapParams.FilterType = Enum.RaycastFilterType.Whitelist

local DamageBlockS = {}
DamageBlockS.__index = DamageBlockS
DamageBlockS.className = "DamageBlock"
DamageBlockS.TAG_NAME = DamageBlockS.className

function DamageBlockS.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
        touching = {},
    }
    setmetatable(self, DamageBlockS)

    if not self:getFields() then return end
    part.CanCollide = false
    part.CanTouch = true
    self:handleTouch()

    return self
end

function DamageBlockS:handleTouch()
    self._maid:Add2(self.part.Touched:Connect(function(hit)
        local char = hit.Parent
        if not char then return end

        if self.touching[char] then return end

        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then return end

        if humanoid.Health <= 0 then return end


        self.touching[char] = self._maid:Add(BigBen.every(1, "Heartbeat", "time_", true):Connect(function(_, timeStep)
            local hits = workspace:GetPartsInPart(self.part, overlapParams)
            local chars = Functional.filterThenMap(hits,
                function(_hit)
                    return _hit.Parent
                end,
                function(_hit)
                    return _hit.Parent
                end
            )
            local stillHitting = table.find(chars, char)
            if not stillHitting then
                self.touching[char]:Destroy() -- Error here
                self.touching[char] = nil
                return
            end
            humanoid.Health = math.max(humanoid.Health - self.part:GetAttribute("damage"), 0)
        end))

    end))
end

function DamageBlockS:getFields()
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

function DamageBlockS:Destroy()
    self._maid:Destroy()
end

return DamageBlockS