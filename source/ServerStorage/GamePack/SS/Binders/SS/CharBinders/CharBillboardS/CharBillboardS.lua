local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

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

local CharBillboardS = {}
CharBillboardS.__index = CharBillboardS
CharBillboardS.className = "CharBillboard"
CharBillboardS.TAG_NAME = CharBillboardS.className

function CharBillboardS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharBillboardS)

    if not self:getFields() then return end
    self:createBillboardGui()
    self:handleGuiUpdates()

    return self
end

local AssetsSs = ServerStorage.Assets
function CharBillboardS:createBillboardGui()
    self.Billboard = AssetsSs.Guis.CharBillboard:Clone()
    self.Billboard.Size = UDim2.fromScale(5, 2.5)
    self.Billboard.Adornee = self.charParts.hrp
    self.Billboard.StudsOffset = Vector3.new(0, 4, 0)
    self.Billboard.Parent = self.char
end

local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function CharBillboardS:handleGuiUpdates()
    do
        local function updateRank(state)
            local rankData = Data.Ranks.Ranks.idData[state.id]
            local Rank = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.Billboard, refName="Rank"})
            if not Rank then return end
            Rank.TextLabel.TextColor3 = rankData.color
            local gpsState = self.playerState:get(S.Stores, "GamePasses")
            local vipGpId = Data.GamePasses.GamePasses.nameToData[S.VipGp].id
            if gpsState.st[vipGpId] then
                Rank.TextLabel.Text = ("👑 %s"):format(rankData.prettyName)
            else
                Rank.TextLabel.Text = rankData.prettyName
            end
        end
        self._maid:Add(self.playerState:getEvent(S.Session, "Rank", "set"):Connect(updateRank))
        local state = self.playerState:get(S.Session, "Rank")
        updateRank(state)
    end
    do
        local function updatePoints(state)
            local Points = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.Billboard, refName="Points"})
            if not Points then return end
            local prettyName = Data.Money.Money[S.Points].prettyName or Data.Money.Money[S.Points].prettyNameShort
            Points.TextLabel.Text = ("%s: %s"):format(
                prettyName, NumberFormatter.numberToEng(state.current))

        end
        self._maid:Add(self.playerState:getEvent(S.Stores, "Points", "Update"):Connect(updatePoints))
        local state = self.playerState:get(S.Stores, "Points")
        updatePoints(state)
    end
    do
        local function updateMoney_1(state)
            local Money_1 = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.Billboard, refName="Money_1"})
            if not Money_1 then return end
            Money_1.TextLabel.Text = ("%s: %s"):format(
                Data.Money.Money[S.Money_1].prettyName, NumberFormatter.numberToEng(state.current))
        end
        self._maid:Add(self.playerState:getEvent(S.Stores, "Money_1", "Update"):Connect(updateMoney_1))
        local state = self.playerState:get(S.Stores, "Money_1")
        updateMoney_1(state)
    end
end

function CharBillboardS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {},
        functions = {},
    }))
end

function CharBillboardS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharBillboardS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharParts", self.char},
                {"CharState", self.char},
                {"CharProps", self.char},
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

function CharBillboardS:Destroy()
    self._maid:Destroy()
end

-- local function updateBillboards()
--     while true do
--         task.wait(1)
--         for _, player in ipairs(Players:GetPlayers()) do
--             local char = player.Character
--             if not (char and char.Parent) then continue end
--             local charBillboardObj = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharBillboard", inst = char})
--             if not charBillboardObj then continue end
    
--         end
--     end
-- end
-- updateBillboards()

return CharBillboardS