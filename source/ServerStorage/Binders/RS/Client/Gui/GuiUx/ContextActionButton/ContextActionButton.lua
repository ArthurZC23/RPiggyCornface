local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Gaia = Mod:find({"Gaia", "Shared"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local TableUtils = Mod:find({"Table", "Utils"})
local S = Data.Strings.Strings
local Debounce = Mod:find({"Debounce", "Debounce"})

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

local ContextActionButton = {}
ContextActionButton.__index = ContextActionButton
ContextActionButton.className = "ContextActionButton"
ContextActionButton.TAG_NAME = ContextActionButton.className

function ContextActionButton.new(btn)
    local self = {
        btn = btn,
        _maid = Maid.new({debug={destroy=false}}),
    }
    setmetatable(self, ContextActionButton)

    btn.Image = "http://www.roblox.com/asset/?id=12989741742"

    if not self:getFields() then return end
    self:getJumpButtonParams()
    self:setUx(btn)

    return self
end

function ContextActionButton:setMobileButtonView(btn, data)
    assert(data.image or data.text)
    btn.AnchorPoint = Vector2.new(0.5, 0)
    local scale = 0.75
    local xOffset
    local yOffset
    if data.idx <= 3 then
        xOffset = UDim2.fromOffset(0, 0)
        yOffset = - UDim2.fromOffset(0, data.idx * 0.8 * self.mobileBtnsRefs.size.Y.Offset)
    else
        xOffset = UDim2.fromOffset(-0.8 * self.mobileBtnsRefs.size.X.Offset, 0)
        yOffset = - UDim2.fromOffset(0, (data.idx - 3) * 0.8 * self.mobileBtnsRefs.size.Y.Offset)
    end
    btn.Position =
        self.mobileBtnsRefs.position
        + xOffset
        + UDim2.fromOffset(0.5 * self.mobileBtnsRefs.size.X.Offset, 0)
        + yOffset
        -- - self.mobileBtnsRefs.offset
    btn.Size = UDim2.fromOffset(scale * self.mobileBtnsRefs.size.X.Offset, scale * self.mobileBtnsRefs.size.Y.Offset)
    if data.image then
        btn.ActionIcon.Image = data.image
    end
    if data.text then
        btn.ActionTitle.Text = data.text
    end
end

function ContextActionButton:getJumpButtonParams()
    self.mobileBtnsRefs = {
        position = self.jumpButton.Position,
        size = UDim2.fromOffset(self.jumpButton.Size.X.Offset, self.jumpButton.Size.Y.Offset),
        offset = UDim2.fromScale(0, 0.025),
        anchorPoint = self.jumpButton.AnchorPoint,
    }
end

function ContextActionButton:onLeft(btn)
    btn.ImageTransparency = 0.4
    btn.ImageColor3 = Color3.fromRGB(0, 0, 0)
end

function ContextActionButton:onTouch(btn)
    btn.ImageTransparency = 0
end

function ContextActionButton:onClickUx(btn)

end

function ContextActionButton:setCallback(kwargs)
    local maid = self._maid:Add2(Maid.new(), "Callbacks")
    local action
    local inputState
    local inputObject
    if kwargs.stopCallback then
        local cb = Debounce.standard(kwargs.stopCallback)
        maid:Add(self.btn.MouseLeave:Connect(function()
            cb(action, inputState, inputObject, kwargs.cbKwargs)
        end))
    end
    if kwargs.startCallback then
        local cb = Debounce.standard(kwargs.startCallback)
        maid:Add(self.btn.MouseEnter:Connect(function()
            cb(action, inputState, inputObject, kwargs.cbKwargs)
        end))
    end
end

function ContextActionButton:setUx(btn)
    self._maid:Add(btn.MouseLeave:Connect(Debounce.standard(function()
        self:onLeft(btn)
    end)))
    self._maid:Add(btn.MouseEnter:Connect(Debounce.standard(function()
        self:onTouch(btn)
    end)))
    -- self._maid:Add(btn.Activated:Connect(Debounce.standard(function()
    --     self:onClickUx(btn)
    -- end)))
    self:onLeft(btn)
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function ContextActionButton:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.jumpButton = ComposedKey.getFirstDescendant(localPlayer, {"PlayerGui", "TouchGui", "TouchControlFrame", "JumpButton"})
            if not self.jumpButton then return end

            return true
        end,
        keepTrying=function()
            return self.btn.Parent
        end,
        cooldown=1
    })
    return ok
end

function ContextActionButton:Destroy()
    self._maid:Destroy()
end

return ContextActionButton