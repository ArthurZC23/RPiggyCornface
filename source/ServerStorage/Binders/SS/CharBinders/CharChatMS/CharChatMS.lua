local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local function setAttributes()
    script:SetAttribute("totalTime", 0.3)
    script:SetAttribute("factor", 12)
end
setAttributes()

local CharChatMS = {}
CharChatMS.__index = CharChatMS
CharChatMS.className = "CharChatM"
CharChatMS.TAG_NAME = CharChatMS.className

function CharChatMS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharChatMS)

    if not self:getFields() then return end
    self:createRemotes()
    self:createPhysics()

    return self
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function CharChatMS:createPhysics()
    local hrp = self.charParts.hrp
    self._maid:Add(GaiaShared.create("VectorForce", {
        Name = "AntiGravity",
        ApplyAtCenterOfMass = true,
        Attachment0 = self.charAttachments.attachs.RootRigAttachment,
        RelativeTo = "World",
        Force = Vector3.new(0, 0, 0),
        Parent = hrp,
    }))
end

function CharChatMS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"ChatM"},
        functions = {},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharChatMS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharParts", self.char},
                {"CharAttachments", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharChatMS:Destroy()
    self._maid:Destroy()
end

return CharChatMS