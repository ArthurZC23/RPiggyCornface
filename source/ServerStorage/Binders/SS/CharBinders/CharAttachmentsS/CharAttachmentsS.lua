local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharData = Data.Char.Char
local GaiaShared = Mod:find({"Gaia", "Shared"})
local TableUtils = Mod:find({"Table", "Utils"})

local CharAttachmentsS = {}
CharAttachmentsS.__index = CharAttachmentsS
CharAttachmentsS.className = "CharAttachments"
CharAttachmentsS.TAG_NAME = CharAttachmentsS.className

function CharAttachmentsS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharAttachmentsS)

    if not self:getFields() then return end
    self:addAttachments()
    if not self:setAttachmentsFields() then return end

    -- if RunService:IsStudio() then
    --     local Functional = Mod:find({"Functional"})
    --     task.delay(10, function()
    --         local attachs = Functional.filter(self.char:GetDescendants(), function(v)
    --             return v:IsA("Attachment")
    --         end)
    --         print("True attach: ", #attachs)
    --     end)
    -- end

    return self
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})

function CharAttachmentsS:addAttachments()
    for attachName, attachData in pairs(CharData[("attachments%s"):format(self.rigType)]) do
        if not attachData.extra then continue end
        local data = TableUtils.deepCopy(attachData)
        data.Name = attachName
        if attachData.ParentPath then
            data.Parent = ComposedKey.getFirstDescendant(self.char, attachData.ParentPath)
        elseif attachData.ParentName then
            data.Parent = self.charParts[data.ParentName]
        else
            error("")
        end
        data.ParentName = nil
        data.ParentPath = nil
        data.extra = nil
        GaiaShared.create("Attachment", data)
    end
end

function CharAttachmentsS:setAttachmentsFields()
    return WaitFor.GetAsync({
        getter=function()
            self.attachs = {}
            for attachKey, attachData in pairs(CharData[("attachments%s"):format(self.rigType)]) do
                local data = TableUtils.deepCopy(attachData)
                local attachName = data.attachName or attachKey
                -- print(attachKey, attachName, data.ParentName)
                local attach
                if data.ParentPath then
                    table.insert(data.ParentPath, attachName)
                    attach = ComposedKey.getFirstDescendant(self.char, data.ParentPath)
                elseif data.ParentName then
                    attach = self.charParts[data.ParentName]:FindFirstChild(attachName)
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
    })
end

function CharAttachmentsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
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

function CharAttachmentsS:Destroy()
    self._maid:Destroy()
end

return CharAttachmentsS