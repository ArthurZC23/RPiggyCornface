local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local IdUtils = Mod:find({"Id", "Utils"})
local TableUtils = Mod:find({"Table", "Utils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local ToolsUtils = Mod:find({"Tools", "Utils"})

local toolIdGen = IdUtils.createNumIdGenerator()

local ToolS = {}
ToolS.__index = ToolS
ToolS.className = "Tool"
ToolS.TAG_NAME = ToolS.className

function ToolS.new(tool)
    if not (tool:IsDescendantOf(workspace) or tool:FindFirstAncestor("Backpack")) then return end

    local self = {
        _maid = Maid.new(),
        tool = tool,
        equipped = false,
    }
    setmetatable(self, ToolS)

    if not self:getFields(tool) then return end
    self:addId()
    self:createRemotes()
    self:initTool()

    return self
end

function ToolS:addId()
    self.toolId = toolIdGen()
    self.tool:SetAttribute("id", self.toolId)
    self.tool:SetAttribute("charUid",  self.charId)
end

function ToolS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {},
        functions = {},
    }))
end

function ToolS:getToolChar(tool)

    return true
end

function ToolS:handleToolEvents(obj)
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

function ToolS:initTool()
    self._maid:Add(self.tool.Unequipped:Connect(function()
        self:unequip()
    end))

    self._maid:Add(self.tool.Equipped:Connect(function()
        self:equip()
    end))

    if ToolsUtils.isToolEquipped(self.tool) then
        self:equip()
    end
end

function ToolS:equip()
    local maid = self._maid:Add2(Maid.new(), "Equip")
end

function ToolS:unequip()
    self._maid:Remove("Equip")
end

function ToolS:activate()

end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function ToolS:getFields(tool)
    return WaitFor.GetAsync({
        getter=function()
            self.player = ToolsUtils.getPlayerFromTool(tool)
            if not self.player then return end

            self.char = self.player.Character
            if not (self.char and self.char.Parent) then return end
            self.charId = self.char:GetAttribute("uid")

            self.rigType = self.char:GetAttribute("rigType")
            if not self.rigType then return nil, "rigType" end

            local bindersData = {
                {"PlayerState", self.player},
                {"CharState", self.char},
                {"CharParts", self.char},
                {"CharAttachments", self.char},
                {"CharAnimationMarkers", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.charId = self.char:GetAttribute("uid")

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
        cooldown=1/60
    })
end

function ToolS:Destroy()
    self._maid:Destroy()
end

return ToolS