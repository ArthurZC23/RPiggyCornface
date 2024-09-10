local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Platforms = Mod:find({"Platforms", "Platforms"})

local localPlayer = Players.LocalPlayer

local OtherGamePortalShowConditionsC = {}
OtherGamePortalShowConditionsC.__index = OtherGamePortalShowConditionsC
OtherGamePortalShowConditionsC.className = "OtherGamePortalShowConditions"
OtherGamePortalShowConditionsC.TAG_NAME = OtherGamePortalShowConditionsC.className

function OtherGamePortalShowConditionsC.new(RootFolder)
    local self = {
        _maid = Maid.new(),
        RootFolder = RootFolder,
        db = false,
    }
    setmetatable(self, OtherGamePortalShowConditionsC)

    if not self:getFields() then return end

    if RunService:IsStudio() then
        -- return
        self:move()
    end
    local function update(state)
        if
            -- state.current.AreAdsAllowed == false and Platforms.getPlatform() == Platforms.Platforms.Mobile
           Platforms.getPlatform() == Platforms.Platforms.Mobile
            or localPlayer.UserId == 925418276
        then
            self:move()
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "PolicyService", "setPoliceService"):Connect(update))
    local state = self.playerState:get(S.Session, "PolicyService")
    update(state)

    return self
end

function OtherGamePortalShowConditionsC:move()
    if self.db then return end
    self.db = true
    local OtherGamePortal = ReplicatedStorage.Assets.Models.OtherGamePortal:Clone()
    OtherGamePortal:PivotTo(self.SRef:GetPivot())
    OtherGamePortal.Parent = self.RootFolder.Model
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
function OtherGamePortalShowConditionsC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.SRef = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootFolder, refName="SRef"})
            if not self.SRef then return end
            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootFolder.Parent
        end,
        cooldown=nil
    })
end

function OtherGamePortalShowConditionsC:Destroy()
    self._maid:Destroy()
end

return OtherGamePortalShowConditionsC