local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local NotificationStreamSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="NotificationStream"})
local FastModeData = Data.Settings.FastMode

local FastModeC = {}
FastModeC.__index = FastModeC
FastModeC.className = "FastMode"
FastModeC.TAG_NAME = FastModeC.className

function FastModeC.new(playerSettings)
    local self = {
        _maid = Maid.new(),
        player = playerSettings.player,
    }
    setmetatable(self, FastModeC)
    if not self:getFields() then return end
    self:handleNotification()
    self:handleMode()

    return self
end

function FastModeC:handleNotification(instance)
    self._maid:Add(self.playerState:getEvent(S.Stores, "Settings", "setFastMode"):Connect(function()
        NotificationStreamSE:Fire({
            Text = ("Restart game to see all the changes!"):format(Platforms:getPlatform(), tostring(UserInputService.TouchEnabled), tostring(UserInputService.MouseEnabled)),
        })
    end))
end

function FastModeC:_removeMaterials(instance)
    instance.Material = Enum.Material.Plastic
    instance.CastShadow = false
end

function FastModeC:_removeTextures(instance)
    instance.Texture = ""
end

function FastModeC:_removeLightSources(instance)
    instance.Enabled = false
end

function FastModeC:_removeShadows(instance)
    instance.CastShadow = false
end

function FastModeC:removeMapExcess(Map)
    for _, desc in ipairs(Map:GetDescendants()) do
        if CollectionService:HasTag(desc, "ModelToDeleteInFastMode") then
            desc:Destroy()
            continue
        end
        if desc:IsA("BasePart") then
            self:_removeMaterials(desc)
            self:_removeShadows(desc)
        elseif desc:IsA("Light") then
            self:_removeLightSources(desc)
        elseif desc:IsA("Texture") then
            self:_removeTextures(desc)
        end
    end
end

function FastModeC:setSuperFastMode(Map)
    self:removeMapExcess(Map)
end

function FastModeC:setFastMode(Map)
    self:removeMapExcess(Map)
end

function FastModeC:setNormalMode(Map)

end

function FastModeC:handleMode()
    local Map = workspace.Map
    local settingsState = self.playerState:get(S.Stores, "Settings")
    local mode = FastModeData.idToName[settingsState.FastMode]
    self[("set%sMode"):format(mode)](self, Map)
end

function FastModeC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
    return ok
end

function FastModeC:Destroy()
    self._maid:Destroy()
end

return FastModeC