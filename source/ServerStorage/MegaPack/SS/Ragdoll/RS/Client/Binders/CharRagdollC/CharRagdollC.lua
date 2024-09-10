local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Promise = Mod:find({"Promise", "Promise"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local binderCharParts = SharedSherlock:find({"Binders", "getBinder"}, {tag="CharParts"})
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local CharRagdollC = {}
CharRagdollC.__index = CharRagdollC
CharRagdollC.className = "CharRagdoll"
CharRagdollC.TAG_NAME = CharRagdollC.className

function CharRagdollC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharRagdollC)

    if not self:getFields() then return end

    self:handleSetRagdoll()

    return self
end

function CharRagdollC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.charParts = binderCharParts:getObj(self.char)
            if not self.charParts then return end

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            -- self.charMovement = binderCharMovement:getObj(self.char)
            -- if not self.charMovement then return end

            self.SetRagdollRE = ComposedKey.getFirstDescendant(self.charEvents, {"Remotes", "Events", "SetRagdoll"})
            if not self.SetRagdollRE then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharRagdollC:handleSetRagdoll()
    self.SetRagdollRE.OnClientEvent:Connect(function(isRagdoll, kwargs)
        self:setRagdoll(isRagdoll, kwargs)
    end)
end

function CharRagdollC:setRagdoll(isRagdoll, kwargs)
    if self.char:GetAttribute("Dead") and (not isRagdoll) then return end
    kwargs = kwargs or {}
    if isRagdoll then
        self.charMovement:lockMovementInput()
        -- if kwargs.AngularImpulse then
        --     local magnitude = kwargs.AngularImpulse
        --     local random = Random.new()
        --     local vec = Vector3.new(
        --         random:NextNumber(),
        --         random:NextNumber(),
        --         random:NextNumber()
        --     ).Unit
        --     self.charParts.hrp:ApplyAngularImpulse(magnitude * vec)
        -- end
        camera.CameraSubject = self.charParts.head
        self.charParts.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        local humanoidState = kwargs.humanoidState or Enum.HumanoidStateType.Ragdoll
        self.charParts.humanoid:ChangeState(humanoidState)
        CollectionService:RemoveTag(self.char, "CharCoreAnimationsR6")
        for _, track in pairs(self.charParts.animator:GetPlayingAnimationTracks()) do
            track:Stop(0)
            -- Promise.fromEvent(track.DidLoop)
            --     :timeout(1)
            --     :finally(function()
            --         track:Stop(0)
            --     end)
        end
    else
        self.charMovement:unlockMovementInput()
        camera.CameraSubject = self.charParts.humanoid
        self.charParts.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        self.charParts.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        CollectionService:AddTag(self.char, "CharCoreAnimationsR6")
    end
end

function CharRagdollC:Destroy()
    self._maid:Destroy()
end

return CharRagdollC