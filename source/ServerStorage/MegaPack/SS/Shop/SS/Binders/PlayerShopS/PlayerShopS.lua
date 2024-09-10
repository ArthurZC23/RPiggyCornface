local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local Promise = Mod:find({"Promise", "Promise"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local PlayerShopS = {}
PlayerShopS.__index = PlayerShopS
PlayerShopS.className = "PlayerShop"
PlayerShopS.TAG_NAME = PlayerShopS.className

local RootF = script:FindFirstAncestor("PlayerShopS")
local Components = {
    CasePurchase = require(ComposedKey.getAsync(RootF, {"Components", "CasePurchaseS"})),
}

function PlayerShopS.new(player)
    local self = {
        _maid = Maid.new(),
        player = player,
        dbs = {},
    }
    setmetatable(self, PlayerShopS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    if not BinderUtils.initComponents(self, Components) then return end

    return self
end

function PlayerShopS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 0.5},
    })
end

function PlayerShopS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"BuyKeys", "BuyCase"},
        functions = {},
    }))
end

function PlayerShopS:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {
                
            }
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
        cooldown=nil
    })
    return ok
end


function PlayerShopS:Destroy()
    self._maid:Destroy()
end

return PlayerShopS