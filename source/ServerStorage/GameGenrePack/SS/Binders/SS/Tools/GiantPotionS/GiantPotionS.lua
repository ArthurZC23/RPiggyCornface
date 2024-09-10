local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local TableUtils = Mod:find({"Table", "Utils"})

local function setAttributes()

end
setAttributes()

local GiantPotionS = {}
GiantPotionS.__index = GiantPotionS
GiantPotionS.className = "GiantPotion"
GiantPotionS.TAG_NAME = GiantPotionS.className

function GiantPotionS.new(Tool)
    local self = {
        Tool = Tool,
        _maid = Maid.new(),
    }
    setmetatable(self, GiantPotionS)

    if not self:getFields() then return end

    self._maid:Add(self.tool:handleToolEvents(self))

    return self
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function GiantPotionS:setItemCFrame()
    local maid = Maid.new()
    self.handle.Anchored = false

    self.itemPart0 = ComposedKey.getFirstDescendant(self.char, {"RightHand"})
    self.attach0 = self.charAttachments.attachs["RightGripAttachment"]

    local GhostPart = maid:Add(GaiaShared.clone(ReplicatedStorage.Assets.Parts.GhostPart, {
        Anchored = false,
        Name = "ToolP",
        Parent = self.char,
    }))
    GhostPart:PivotTo(self.attach0.WorldCFrame)
    local attach1 = GaiaShared.create("Attachment", {
        Name = "A1",
        Parent = GhostPart,
    })

    GaiaShared.create("RigidConstraint", {
        Parent = GhostPart,
        Attachment0 = attach1,
        Attachment1 = self.attach0,
    })

    local motor = maid:Add(GaiaShared.create("Motor6D", {
        Part0 = GhostPart,
        Part1 = self.handle,
        C0 = CFrame.new(0, 0, 0),
        C1 = CFrame.new(0, 0, 0),
        Name = "ToolRoot",
        Parent = self.handle,
    }))
    maid:Add(function()
        motor:Destroy()
        self.Tool:PivotTo(self.Tool:GetPivot() + 1e3 * Vector3.yAxis)
    end)

    return maid
end

function GiantPotionS:equip()
    local maid = self._maid:Add2(Maid.new(), "Equip")
    maid:Add(self:setItemCFrame())
end

function GiantPotionS:unequip()
    self._maid:Remove("Equip")
end

local S = Data.Strings.Strings
local BoostsUtils = Mod:find({"Boosts", "SS", "Utils"})
function GiantPotionS:consume()
    local itemId = self.Tool:GetAttribute("itemId")
    local itemData = Data.Items.Items.idData[itemId]
    local boostData = itemData.boost

    BoostsUtils.giveBoost(self.playerState, boostData.id, boostData.duration)

    do
        local action = {
            name = "remove",
            id = itemId,
        }
        self.playerState:set(S.Session, "Items", action)
    end
end

function GiantPotionS:activated()
    self:consume()
end

function GiantPotionS:deactivated()

end

function GiantPotionS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            do
                local bindersData = {
                    {"Tool", self.Tool},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end
            self.char = self.tool.char
            self.handle = self.tool.handle

            self.player = self.tool.player

            do
                local bindersData = {
                    {"PlayerState", self.player},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            do
                local bindersData = {
                    {"CharState", self.char},
                    {"CharParts", self.char},
                    {"CharProps", self.char},
                    {"CharAttachments", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end

            return true
        end,
        keepTrying=function()
            return self.Tool.Parent
        end,
        cooldown=1
    })
end

function GiantPotionS:Destroy()
    self._maid:Destroy()
end

return GiantPotionS