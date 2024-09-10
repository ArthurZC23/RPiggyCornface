local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local ToolsUtils = Mod:find({"Tools", "Utils"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local localPlayer = Players.LocalPlayer

local ToolC = {}
ToolC.__index = ToolC
ToolC.className = "Tool"
ToolC.TAG_NAME = ToolC.className

function ToolC.new(tool)
    if not (tool:IsDescendantOf(workspace) or tool:FindFirstAncestor("Backpack")) then return end

    local self = {
        _maid = Maid.new(),
        tool = tool,
    }
    setmetatable(self, ToolC)

    if not self:getFields(tool) then return end
    self.isLocalChar = self:isLocalCharTheOwner()

    return self
end

function ToolC:equip()

end

function ToolC:unequip()

end

function ToolC:handleToolEvents(obj)
    local maid = Maid.new()
    maid:Add(self.tool.Unequipped:Connect(function()
        obj:unequip()
    end))

    maid:Add(self.tool.Equipped:Connect(function()
        obj:equip()
    end))

    if ToolsUtils.isToolEquipped(self.tool) then
        obj:equip()
    end

    maid:Add(self.tool.Activated:Connect(function()
        obj:activated()
    end))

    maid:Add(self.tool.Deactivated:Connect(function()
        obj:deactivated()
    end))

    return maid
end

function ToolC:isLocalCharTheOwner()
    return localPlayer == self.player
end


function ToolC:getFields(tool)
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.player = ToolsUtils.getPlayerFromTool(tool)
            if not self.player then return end

            self.char = self.player.Character
            if not (self.char and self.char.Parent) then return end
            self.charId = self.char:GetAttribute("uid")

            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return nil, "rigType" end

            self.toolId = self.tool:GetAttribute("id")
            if not self.toolId then return end

            -- Need this on client
            self.toolCharUid = tool:GetAttribute("charUid")
            if self.charId ~= self.toolCharUid then return end

            local bindersData = {
                {"CharParts", self.char},
                {"CharAnimationMarkers", self.char},
                {"CharAttachments", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            if self.tool.RequiresHandle then
                self.handle = tool:FindFirstChild("Handle")
                if not self.handle  then return end
            else
                self.handle = ComposedKey.getFirstDescendant(self.tool, {"Skeleton", "Handle"})
                if not self.handle then return end

                self.handleAttach = ComposedKey.getFirstDescendant(self.handle, {"A0"})
                if not self.handleAttach then return end
            end

            self.backpack = self.player:FindFirstChild("Backpack")
            if not self.backpack then return end

            return true
        end,
        keepTrying=function()
            return tool.Parent
        end,
    })
    return ok
end

function ToolC:Destroy()
    self._maid:Destroy()
end

return ToolC