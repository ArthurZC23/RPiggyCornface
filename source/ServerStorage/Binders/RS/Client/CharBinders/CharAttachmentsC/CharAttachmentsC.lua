local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharData = Data.Char.Char
local SharedSherlock = require(ReplicatedStorage.Sherlocks.Shared.SharedSherlock)
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharAttachmentsC = {}
CharAttachmentsC.__index = CharAttachmentsC
CharAttachmentsC.className = "CharAttachments"
CharAttachmentsC.TAG_NAME = CharAttachmentsC.className

function CharAttachmentsC.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharAttachmentsC)

    if not self:getFields() then return end
    if not self:setAttachmentsFields() then return end

    return self
end

local TableUtils = Mod:find({"Table", "Utils"})
function CharAttachmentsC:setAttachmentsFields()
    return WaitFor.GetAsync({
        getter=function()
            self.attachs = {}
            for attachKey, attachData in pairs(CharData[("attachments%s"):format(self.rigType)]) do
                local data = TableUtils.deepCopy(attachData)
                local attachName = data.attachName or attachKey
                local attach
                if data.ParentPath then
                    table.insert(data.ParentPath, attachName)
                    attach = ComposedKey.getFirstDescendant(self.char, data.ParentPath)
                elseif data.ParentName then
                    local attachParent = self.charParts[data.ParentName]
                    if not attachParent then return end
                    attach = attachParent:FindFirstChild(attachName)
                else
                    error("")
                end
                local userId = tostring(self.charParts.player.UserId)
                if not attach then return nil, ("Attachment: %s\nPlayer: %s"):format(attachName, userId) end
                self.attachs[attachKey] = attach
            end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        attempts = 60 * 10,
    })
end

function CharAttachmentsC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
end

function CharAttachmentsC:Destroy()
    self._maid:Destroy()
end

return CharAttachmentsC