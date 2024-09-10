local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharItemsS = {}
CharItemsS.__index = CharItemsS
CharItemsS.className = "CharItems"
CharItemsS.TAG_NAME = CharItemsS.className

function CharItemsS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
        tools = {},
    }
    setmetatable(self, CharItemsS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleBuyItems()
    self:handleStash()

    return self
end

local TableUtils = Mod:find({"Table", "Utils"})
local BEvents = ComposedKey.getAsync(ReplicatedStorage, {"Bindables", "Events"})
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

function CharItemsS:canBuyItems(carryData)
    carryData.itemState = self.playerState:get(S.Session, "Items")
    if TableUtils.len(carryData.itemState.st) >= 2 then
        NotificationStreamRE:FireClient(self.player, {
            Text = ("You can only carry 2 items."),
        })
        return
    end
    if carryData.itemState.st[carryData.itemId] then
        NotificationStreamRE:FireClient(self.player, {
            Text = ("You can only have 1 of each item in backpack"),
        })
        return
    end
    carryData.itemData = Data.Items.Items.idData[carryData.itemId]
    carryData.shopData = carryData.itemData.rewards.shop
    if carryData.shopData._type == "Money" then
        carryData.moneyState = self.playerState:get(S.Stores, carryData.shopData.moneyType)
        if carryData.moneyState.current < carryData.shopData.price then
            NotificationStreamRE:FireClient(self.player, {
                Text = ("Not enough money."),
            })
            return
        end
    else
        return
    end

    return true
end

function CharItemsS:handleBuyItems()
    self.network:Connect(self.BuyItemRE.OnServerEvent, function(player, itemId)
        local carryData = {
            itemId = itemId,
        }
        if not self:canBuyItems(carryData) then return end
        do
            local action = {
                name = "add",
                id = carryData.itemId,
            }
            self.playerState:set(S.Session, "Items", action)
        end
        do
            local action = {
                name = "Decrement",
                value = carryData.shopData.price,
                ux = true,
            }
            self.playerState:set(S.Stores, carryData.shopData.moneyType, action)
        end
    end)
end

local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
function CharItemsS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 1},
    })
end

function CharItemsS:handleStash()
    local function removeItem(_, action)
        local tool = self.tools[action.id]
        self.tools[action.id] = nil
        tool:Destroy()
    end
    local function addItem(_, action)
        local toolId = action.id
        local toolData = Data.Items.Items.idData[toolId]
        local tool = ReplicatedStorage.Assets.Items.Tools[toolData.name]:Clone()
        self.tools[toolId] = tool
        tool.Name = toolData.viewName
        tool:AddTag("Tool")
        for _, tag in ipairs(toolData.tags) do
            tool:AddTag(tag)
        end
        local Backpack = ComposedKey.getFirstDescendant(self.player, {"Backpack"})
        tool.Parent = Backpack
    end

    self._maid:Add(self.playerState:getEvent(S.Session, "Items", "remove"):Connect(removeItem))
    self._maid:Add(self.playerState:getEvent(S.Session, "Items", "add"):Connect(addItem))
    local state = self.playerState:get(S.Session, "Items")
    for id in pairs(state.st) do
        addItem(nil, {id = id})
    end
end

function CharItemsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"BuyItem"},
        functions = {},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharItemsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharState", self.char},
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharItemsS:Destroy()
    self._maid:Destroy()
end

return CharItemsS