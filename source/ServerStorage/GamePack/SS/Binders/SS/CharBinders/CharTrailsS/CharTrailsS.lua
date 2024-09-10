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

local CharTrailsS = {}
CharTrailsS.__index = CharTrailsS
CharTrailsS.className = "CharTrails"
CharTrailsS.TAG_NAME = CharTrailsS.className

function CharTrailsS.new(char)
    if char:HasTag("PlayerMonster") then return end
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharTrailsS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleTrailAttachToChar()
    self:handleTrailPurchase()
    self:handleTrailEquip()

    return self
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function CharTrailsS:handleTrailAttachToChar()
    local function update(state)
        local maid = self._maid:Add2(Maid.new(), "UpdateTrailAttachToChar")
        local A0 = self.charAttachments.attachs.NeckRigAttachment_UpperTorso
        local A1 = self.charAttachments.attachs.WaistRigAttachment_LowerTorso
        local trailId = state.eq
        if not trailId then return end
        local trailData = Data.Trails.Trails.idData[trailId]
        local Trail = maid:Add(GaiaShared.create("Trail", trailData.trailProps))

        Trail.Attachment0 = A0
        Trail.Attachment1 = A1
        Trail.Parent = self.char
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Trails", "unequip"):Connect(update))
    self._maid:Add(self.playerState:getEvent(S.Stores, "Trails", "equip"):Connect(update))
    local state = self.playerState:get(S.Stores, "Trails")
    update(state)
end

function CharTrailsS:handleTrailPurchase()
    local function update(scoreState)
        local score = scoreState[S.FinishChapter]["allTime"]
        local trailState = self.playerState:get(S.Stores, "Trails")
        for trailId, trailData in pairs(Data.Trails.Trails.idData) do
            local shopData = trailData.rewards.shop
            if trailState.st[trailId] then continue end
            if shopData._type == "free" then
                do
                    local action = {
                        name = "add",
                        id = trailId,
                    }
                    self.playerState:set(S.Stores, "Trails", action)
                end
            elseif shopData._type == S.FinishChapter then
                if shopData.price > score then continue end
                do
                    local action = {
                        name = "add",
                        id = trailId,
                    }
                    self.playerState:set(S.Stores, "Trails", action)
                end
            end
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "Scores", "set"):Connect(update))
    local state = self.playerState:get(S.Stores, "Scores")
    update(state)
end

function CharTrailsS:handleTrailEquip()
    self.network:Connect(self.EquipTrailRE.OnServerEvent, function(player, trailId, kwargs)
        kwargs = kwargs or {}
        local trailState = self.playerState:get(S.Stores, "Trails")
        if kwargs.unequip then
            do
                local action = {
                    name = "unequip",
                }
                self.playerState:set(S.Stores, "Trails", action)
            end
            return
        end
        if not trailState.st[trailId] then
            return
        end
        do
            local action = {
                name = "unequip",
            }
            self.playerState:set(S.Stores, "Trails", action)
        end
        do
            local action = {
                name = "equip",
                id = trailId,
            }
            self.playerState:set(S.Stores, "Trails", action)
        end
    end)
end

function CharTrailsS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"EquipTrail", "PurchaseTrail"},
        functions = {},
    }))
end

function CharTrailsS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
    self.network:addDebounce({
        args={self.player, 0.5},
    })
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharTrailsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharParts", self.char},
                {"CharState", self.char},
                {"CharProps", self.char},
                {"CharAttachments", self.char},
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

function CharTrailsS:Destroy()
    self._maid:Destroy()
end

return CharTrailsS