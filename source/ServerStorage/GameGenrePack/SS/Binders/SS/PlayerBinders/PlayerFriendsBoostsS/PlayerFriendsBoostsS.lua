local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local TableUtils = Mod:find({"Table", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local PlayerFriendsBoostsS = {}
PlayerFriendsBoostsS.__index = PlayerFriendsBoostsS
PlayerFriendsBoostsS.className = "PlayerFriendsBoosts"
PlayerFriendsBoostsS.TAG_NAME = PlayerFriendsBoostsS.className

function PlayerFriendsBoostsS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerFriendsBoostsS)

    if not self:getFields() then return end
    self:handleBoosts()

    return self
end

function PlayerFriendsBoostsS:handleBoosts()
    local function update(state)
        local MultipliersData = Data.Hamilton.Multipliers
        local multiplierState = self.playerState:get("Session", "Multipliers")
        local oldMultiplier = multiplierState[MultipliersData.names[S.Friends]]
        local numFriends = state.numFriends
        local multiplier = 1 + (numFriends / Data.Game.Game.maxPlayers)
        local newAction = {
            name = "updateMultiplier",
            value = multiplier,
            multiplier = S.Friends
        }
        self.playerState:set(S.Session, "Multipliers", newAction)
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "Friends", "UpdateNumberFriends"):Connect(update))
    local state = self.playerState:get(S.Session, "Friends")
    update(state)
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerFriendsBoostsS:getFields()
    return WaitFor.GetAsync({
        getter=function()

            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerFriendsBoostsS:Destroy()
    self._maid:Destroy()
end

return PlayerFriendsBoostsS