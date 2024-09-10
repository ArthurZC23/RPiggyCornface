local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local function setAttributes()
    script:SetAttribute("totalTime", 0.3)
    script:SetAttribute("factor", 12)
end
setAttributes()

local CharChatMC = {}
CharChatMC.__index = CharChatMC
CharChatMC.className = "CharChatM"
CharChatMC.TAG_NAME = CharChatMC.className

function CharChatMC.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharChatMC)

    if not self:getFields() then return end
    self:createSignals()
    self:handleCharChatM()

    return self
end

function CharChatMC:handleCharChatM()

    local function handle(v0x, v0y, dirH)
        local maid = self._maid:Add2(Maid.new(), "F")
        local charMass = self.charParts.hrp.AssemblyMass
        maid:Add(function()
            self.antiGravity.Force = Vector3.new(0, 0, 0)
        end)
        self.antiGravity.Force = Vector3.new(0, charMass * workspace.Gravity, 0)
        local t = 0
        repeat
            local _, step = RunService.Stepped:Wait()
            self.charParts.hrp.Velocity = v0x * dirH + (script:GetAttribute("factor") * v0y - script:GetAttribute("factor") * 9.8 * t) * Vector3.new(0, 1, 0)
            t = t + step
        until t > script:GetAttribute("totalTime")
        self._maid:Remove("F")
    end

    self._maid:Add(self.ChatMSE:Connect(handle))
    self._maid:Add(self.ChatMRE.OnClientEvent:Connect(handle))
end

function CharChatMC:createSignals()
    return self._maid:Add(GaiaShared.createBinderSignals(self, self.char, {
        events = {"ChatM"},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharChatMC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.ChatMRE = ComposedKey.getEvent(self.char, "ChatM")
            if not self.ChatMRE then return end

            self.antiGravity = ComposedKey.getFirstDescendant(self.charParts.hrp, {"AntiGravity"})
            if not self.antiGravity then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharChatMC:Destroy()
    self._maid:Destroy()
end

return CharChatMC