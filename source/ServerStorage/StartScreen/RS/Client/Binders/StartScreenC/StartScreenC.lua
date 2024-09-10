local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Helios = SharedSherlock:find({"Singletons", "async"}, {name="Helios"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local IdUtils = Mod:find({"Id", "Utils"})

local DisableGuisSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="DisableGuis"})

local Blur = Lighting.Blur

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local StartScreenC = {}
StartScreenC.__index = StartScreenC
StartScreenC.className = "StartScreen"
StartScreenC.TAG_NAME = StartScreenC.className

function StartScreenC.new(player)
    if not Data.Studio.Studio.startScreen then return end
    if player ~= localPlayer then return end

    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, StartScreenC)


    if not self:getFields() then return end
    self:setWalkSpeedAndJumpPower()
    self:handleCamera()
    self:setLighting()
    self:showGui()
    -- self:setCharacterRig()
    return self
end

local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function StartScreenC:setCharacterRig()
    local charRef = SharedSherlock:find({"EzRef", "Get"}, {inst=workspace.Map.StartScreen, refName="StartScreenCharRef"})
    local rootF = charRef.Parent
    rootF.Player:Destroy()

    local data = {}
    WaitFor.Get({
        getter = function()
            local char = self.player.Character
            if not (char and char.Parent) then return end
            data.char = char

            return true
        end,
        keepTrying = function()
            return self.player.Parent
        end,
    })
    :andThenPromise(function()
        return WaitFor.BObj(data.char, "CharParts")
    end)
    :andThenPromise(function()
        local _char = data.char
        _char.Archivable = true
        local char = _char:Clone()
        _char.Archivable = false

        local shirt = char:FindFirstChild("Shirt")
        if shirt then
            shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=14110815428"
        end
        local pants = char:FindFirstChild("Pants")
        if pants then
            pants.PantsTemplate = "http://www.roblox.com/asset/?id=14110819461"
        end
        char:PivotTo(charRef:GetPivot())
        for _, tag in ipairs(CollectionService:GetTags(char)) do
            if tag == "CharParts" then continue end
            CollectionService:RemoveTag(char, tag)
        end
        local morph = char:FindFirstChild("Morph")
        if morph then
            morph:Destroy()
        end
        local Animate = char:FindFirstChild("Animate")
        if Animate then
            Animate:Destroy()
        end

        CollectionService:AddTag(char, "CharParts")
        CollectionService:AddTag(char, "NpcCoreAnimationsR15")
        CollectionService:AddTag(char, "CutsceneDummy")

        for _, desc in ipairs(char:GetDescendants()) do
            if not desc:IsA("BasePart") then continue end
            if desc.Name == "HumanoidRootPart" then continue end
            desc.Transparency = 0
        end
        char.Parent = rootF
    end)
end

function StartScreenC:setWalkSpeedAndJumpPower()
    self.charProps.props[self.charParts.humanoid]:set("WalkSpeed", "StartScreen", 0)
    self.charProps.props[self.charParts.humanoid]:set("JumpPower", "StartScreen", 0)
    self._maid:Add(function()
        self.charProps.props[self.charParts.humanoid]:removeCause("WalkSpeed", "StartScreen")
        self.charProps.props[self.charParts.humanoid]:removeCause("JumpPower", "StartScreen")
    end)
end

function StartScreenC:setLighting()
    -- Helios.props[Blur]:set("Size", "LoadingScreen", 20)
    -- self._maid:Add(function()
    --     Helios.props[Blur]:removeCause("Size", "LoadingScreen")
    -- end)
end

local function setAttributes()
    script:SetAttribute("omega", 7)
end
setAttributes()

function StartScreenC:handleCamera()
    local CameraWps = workspace.CameraWps.StartScreen
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CameraWps["1"].CFrame
    self._maid:Add(function()
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = self.charParts.humanoid
        camera.CFrame = self.charParts.hrp.CFrame - 10 * self.charParts.hrp.CFrame.LookVector + 5 * self.charParts.hrp.CFrame.RightVector
    end)
end

function StartScreenC:showGui()
    local view = self.controller.view
    view:showStartScreen()
    DisableGuisSE:Fire("Disable", "exceptions", {
        ["Fade"] = true,
        ["StartScreen"] = true,
        ["LoadingScreen"] = true,
    })
    self._maid:Add(function()
        DisableGuisSE:Fire("Enable")
        self:playAnimation()
        :finally(function()
            view:hideStartScreen()
        end)
    end)
end

function StartScreenC:playAnimation()
    return Promise.resolve()
end

function StartScreenC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.char = self.player.Character
            if not self.char then return end
            local bindersData = {
                {"PlayerGuis", self.player},
                {"CharParts", self.char},
                {"CharProps", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.controller = self.playerGuis.controllers.StartScreenController
            if not self.controller then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function StartScreenC:Destroy()
    self._maid:Destroy()
end

return StartScreenC