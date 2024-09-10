local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})

local MapTeleportC = {}
MapTeleportC.__index = MapTeleportC
MapTeleportC.className = "MapTeleport"
MapTeleportC.TAG_NAME = MapTeleportC.className

MapTeleportC.bag = {}

function MapTeleportC.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, MapTeleportC)

    if not self:getFields() then return end
    self:addObjToBag()

    return self
end

local NotificationStreamSE = SharedSherlock:find({"Bindable", "async"}, {root=ReplicatedStorage, signal="NotificationStream"})
function MapTeleportC:requestTeleport(playerState, charState)
    -- Check if it's in vehicle in CharTeleportInGameC
    local interactionState = charState:get(S.Session, "Interactions")
    if next(interactionState.current) then
        NotificationStreamSE:Fire({
            Text = ("Cannot teleport while interacting with another player."),
        })
        return
    end
    local action = {
        name = "teleport",
        cf = self.part.CFrame,
        kwargs = {
            hooks = {
                name = "Gui"
            }
        },
    }
    playerState:set(S.LocalSession, "Teleport", action)
end

function MapTeleportC:addObjToBag()
    local id = self.part:GetAttribute("id")
    MapTeleportC.bag[id] = self
end

local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function MapTeleportC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

             return true
        end,
        keepTrying=function()
            return self.part.Parent
        end,
        cooldown=nil
    })
end

function MapTeleportC:Destroy()
    self._maid:Destroy()
end

return MapTeleportC