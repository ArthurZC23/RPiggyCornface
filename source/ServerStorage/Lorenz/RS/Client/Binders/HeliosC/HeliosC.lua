local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local LightingConfigs = Data.Lighting.Lighting.configs
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SingletonsManager = Mod:find({"Singleton", "Manager"})
local Props = Mod:find({"Props", "Props"})
local FastModeData = Data.Settings.FastMode

local localPlayer = Players.LocalPlayer

local HeliosC = {}
HeliosC.__index = HeliosC
HeliosC.className = "Helios"
HeliosC.TAG_NAME = HeliosC.className

function HeliosC.new()
    local self = {
        props = {},
    }
    setmetatable(self, HeliosC)
    if not self:getFields() then return end
    -- self:setLighting()
    -- self:handleTimeOfDayReplication()

    return self
end

function HeliosC:setLighting()
    local settingsState = self.playerState:get(S.Stores, "Settings")
    local mode = FastModeData.idToName[settingsState.FastMode]
    if mode == "Fast" then
        Lighting.DepthOfField:Destroy()
        Lighting.GlobalShadows = false
    end
    local instances = Lighting:GetDescendants()
    table.insert(instances, Lighting)
    local cause = "Default"
    for _, inst in ipairs(instances) do
        self.props[inst] = Props.new(inst)
        local config = LightingConfigs.default[inst.Name]
        for k, v in pairs(config) do
            self.props[inst]:set(k, cause, v)
        end
    end
end

-- function HeliosC:handleTimeOfDayReplication()
--     workspace:GetAttributeChangedSignal("TimeOfDay"):Connect(function()
--         local minutesAfterMidnight = workspace:GetAttribute("TimeOfDay")
--         self.props[Lighting]:set("TimeOfDay", "Default", function()
--             Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)
--         end)
--     end)
-- end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function HeliosC:getFields()
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
            return localPlayer.Parent
        end,
        cooldown=1
    })
end

function HeliosC:Destroy()
    self._maid:Destroy()
end

SingletonsManager.addSingleton(HeliosC.className, HeliosC.new())

return HeliosC