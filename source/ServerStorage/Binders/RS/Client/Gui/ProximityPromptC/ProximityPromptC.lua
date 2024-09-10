local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local ClientSherlock = Mod:find({"Sherlocks", "Client"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})

local RootF = script:FindFirstAncestor("ProximityPromptC")
local Callbacks = require(ComposedKey.getAsync(RootF, {"Callbacks", "Callbacks"}))

local localPlayer = Players.LocalPlayer
local pageManager = ClientSherlock:find({"PageManager", "FrontPage"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local ProximityPromptC = {}
ProximityPromptC.__index = ProximityPromptC
ProximityPromptC.className = "ProximityPrompt"
ProximityPromptC.TAG_NAME = ProximityPromptC.className

local function validate(p0, cb, kwargs)
    kwargs = kwargs or {}
    return function()
        local char = localPlayer.Character
        if not (char and char.Parent) then return end
        local cPos = char:GetPivot().Position
        local distanceThreshold = kwargs.distanceThreshold or 200
        if (cPos - p0).Magnitude > distanceThreshold then return end
        cb(kwargs)
    end
end

function ProximityPromptC.new(proximityPrompt)
    local parent = proximityPrompt.Parent
    local cbId = proximityPrompt:GetAttribute("ProxPromptCb")
    assert(parent:IsA("Attachment") or parent:IsA("BasePart"))

    local self = {
        _maid = Maid.new(),
        proximityPrompt = proximityPrompt
    }
    setmetatable(self, ProximityPromptC)
    if not self:getFields() then return end

    self._maid:Add2(pageManager.ClosePageSE:Connect(function()
        proximityPrompt.Enabled = true
    end))
    self._maid:Add2(pageManager.OpenPageSE:Connect(function()
        proximityPrompt.Enabled = false
    end))
    if cbId then
        local cb = Callbacks[cbId]
        local pos
        if parent:IsA("Attachment") then
            pos = parent.WorldPosition
        elseif parent:IsA("BasePart") then
            pos = parent.Position
        end
        self._maid:Add2(proximityPrompt.Triggered:Connect(validate(pos, cb, {
            playerState = self.playerState,
            proximityPrompt = proximityPrompt,
        })))
    end
end

function ProximityPromptC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {

            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.proximityPrompt.Parent
        end,
        cooldown=nil
    })
end

return ProximityPromptC