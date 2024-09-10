local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Platforms = Mod:find({"Platforms", "Platforms"})

local RootF = script:FindFirstAncestor("PlayerSettingsS")
local Components = {
    -- FastMode = require(ComposedKey.getAsync(RootF, {"Components", "FastModeS", "FastModeS"})),
}

-- local InputMaps = Data.ContextActions.InputMaps

local PlayerSettingsS = {}
PlayerSettingsS.__index = PlayerSettingsS
PlayerSettingsS.className = "PlayerSettings"
PlayerSettingsS.TAG_NAME = PlayerSettingsS.className

function PlayerSettingsS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
    }
    setmetatable(self, PlayerSettingsS)

    if not self:getFields() then return end
    if not BinderUtils.initComponents(self, Components) then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleSettings()

    return self
end

function PlayerSettingsS:handleSettings()
    self.network:Connect(self.SetSettingsRE.OnServerEvent, function(player, setting, kwargs)
        if setting == "Music" then
            local toggleValue = kwargs.v
            assert(typeof(toggleValue) == "boolean")
            WaitFor.BObj(player, "PlayerState")
            :now()
            :andThen(function(playerState)
                local action = {
                    name = "setMusic",
                    value = toggleValue,
                }
                playerState:set(S.Stores, "Settings", action)
            end)
        else
            error("Error.")
        end
    end)
end

function PlayerSettingsS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 0.5},
    })
end

function PlayerSettingsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"SetSettings"},
        functions = {},
    }))
end

function PlayerSettingsS:getFields()
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
        cooldown=1
    })
    return ok
end


function PlayerSettingsS:Destroy()
    self._maid:Destroy()
end

return PlayerSettingsS