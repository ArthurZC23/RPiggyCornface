local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local KillBlockS = {}
KillBlockS.__index = KillBlockS
KillBlockS.className = "KillBlock"
KillBlockS.TAG_NAME = KillBlockS.className

function KillBlockS.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, KillBlockS)

    if not self:getFields() then return end
    part.CanTouch = true
    self:handleTouch()

    return self
end

function KillBlockS:handleTouch()
    self._maid:Add2(self.part.Touched:Connect(function(hit)
        local parent = hit.Parent
        if not parent then return end

        local humanoid = parent:FindFirstChild("Humanoid")
        if not humanoid then return end
        if humanoid.Health <= 0 then return end
        humanoid.Health = 0
    end))
end



function KillBlockS:getFields()
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

function KillBlockS:Destroy()
    self._maid:Destroy()
end

return KillBlockS