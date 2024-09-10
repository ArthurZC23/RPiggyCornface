local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local PlayerReplicateAssetsS = {}
PlayerReplicateAssetsS.__index = PlayerReplicateAssetsS
PlayerReplicateAssetsS.className = "PlayerReplicateAssets"
PlayerReplicateAssetsS.TAG_NAME = PlayerReplicateAssetsS.className

function PlayerReplicateAssetsS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerReplicateAssetsS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleGetAssets()

    return self
end

function PlayerReplicateAssetsS:handleGetAssets()
    self.network:Connect(self.GetAssetRE.OnServerEvent, function(player, cbId, kwargs)
        self[("_get%s"):format(cbId)](self, kwargs)
    end)
end

local Players = game:GetService("Players")
function PlayerReplicateAssetsS:_getChar(kwargs)
    local userId = kwargs.userId
    local player = Players:GetPlayerByUserId(userId)
    self._maid:Add2(WaitFor.Get({
        getter = function()
            local char = player.Character
            if not (char and char.Parent) then return end
        end,
        keepTrying = function()
            return player.Parent
        end,
    })
    :andThen(function(char)
        return WaitFor.BObj(char, "CharParts")

    end))

end

function PlayerReplicateAssetsS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function PlayerReplicateAssetsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"GetAsset"},
        functions = {},
    }))
end

function PlayerReplicateAssetsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local charId = self.char:GetAttribute("uid")
            self.charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
            if not self.charEvents then return end

            local bindersData = {
                {"PlayerState", self.player},
                {"CharState", self.char},
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
end

function PlayerReplicateAssetsS:Destroy()
    self._maid:Destroy()
end

return PlayerReplicateAssetsS