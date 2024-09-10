local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local LocalData = Mod:find({"Data", "LocalData"})
local CameraData = LocalData.Camera.Camera
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local Props = Mod:find({"Props", "Props"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local CameraModule = Mod:find({"Camera", "RbxCameraModules", "CameraModule"})

local RootF = script:FindFirstAncestor("CharCameraC")
local Components = {
    
}

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local CharCameraC = {}
CharCameraC.__index = CharCameraC
CharCameraC.className = "CharCamera"
CharCameraC.TAG_NAME = CharCameraC.className

for _, cClass in pairs(Components) do
    setmetatable(cClass, CharCameraC)
end

function CharCameraC.new(char)
    -- char is nil
    if char.Parent == nil then
        local traceback = debug.traceback(nil, 1)
        task.spawn(function()
            local str1 = "AAAAAAAAAAAA"
            local str2 = "char Parent is nil during instancing"
            task.wait()
            local str3 = ("task.wait() char Parent: %s"):format(tostring(char.Parent))
            task.wait(10/60)
            local str4 = ("task.wait() char Parent: %s"):format(tostring(char.Parent))
            task.wait(1)
            local str5 = ("task.wait() char Parent: %s"):format(tostring(char.Parent))
            local str = table.concat({str1, str2, str3, str4, str5, traceback}, "\n\n")
            error(str)
        end)
    end
    local isLocalChar, player = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        player = player,
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharCameraC)

    if not self:getFields() then return end
    -- self:handleCameraLock()
    self:createCameraProp()
    if not self:initComponents() then return end

    return self
end

function CharCameraC:handleCameraLock()
    local platform = Platforms.getPlatform()
    if platform == Platforms.Platforms.Mobile or platform == Platforms.Platforms.Console then
        if RunService:IsStudio() and Data.Studio.Studio.camera.ignoreCameraLock then return end

        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = self.charParts.humanoid
        self._maid:Add2(WaitFor.Value(CameraModule, {"activeCameraController"}, {
            keepTrying = function()
                return self.char.Parent
            end,
            cooldown = 1,
            attempts = 15,
        })
        :andThen(function(activeCameraController)
            activeCameraController:SetIsMouseLocked(true)
        end))
    end
end

function CharCameraC:initComponents()
    for cName, cClass in pairs(Components) do
        local obj = cClass.new(self)
        if obj then
            self[cName] = self._maid:Add(obj)
       else
            return false
        end
    end
    return true
end

function CharCameraC:createCameraProp()
    self.props = self._maid:Add(Props.new(camera))
    local cause = "Default"
    self.props:addToPq("CameraSubject", cause, self.charParts.humanoid)
    self.props:addToPq("CameraType", cause, Enum.CameraType.Custom)
    self.props:addToPq("FieldOfView", cause, 128.079)
    self.props:set("CameraMinZoomDistance", cause, function()
        localPlayer.CameraMinZoomDistance = CameraData.Zoom.Default.CameraMinZoomDistance
    end)
    self.props:set("CameraMaxZoomDistance", cause, function()
        localPlayer.CameraMaxZoomDistance = CameraData.Zoom.Default.CameraMaxZoomDistance
    end)
end

function CharCameraC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
                {"CharState", self.char},
                {"CharParts", self.char},
                -- {"CharMovement", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.humanoid = self.charParts.humanoid
            self.hrp = self.charParts.hrp
            self.animator = self.charParts.animator

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
    return ok
end

function CharCameraC:Destroy()
    self._maid:Destroy()
end

return CharCameraC