local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})
local TableUtils = Mod:find({"Table", "Utils"})

local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})

local function setAttributes()

end
setAttributes()

local PlayerFinishGameS = {}
PlayerFinishGameS.__index = PlayerFinishGameS
PlayerFinishGameS.className = "PlayerFinishGame"
PlayerFinishGameS.TAG_NAME = PlayerFinishGameS.className

function PlayerFinishGameS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerFinishGameS)

    if not self:getFields() then return end
    self:setPlayerNetwork()
    self:createRemotes()
    self:handleFinishGame()

    return self
end

local Calculators = Mod:find({"Hamilton", "Calculators", "Calculators"})
local Promise = Mod:find({"Promise", "Promise"})
function PlayerFinishGameS:handleFinishGame()
    self.network:Connect(self.FinishGameRE.OnServerEvent, function(player)
        local mapTokenState = self.playerState:get(S.Session, "MapTokens")
        if mapTokenState.total ~= Data.Map.Map.numberTokens then return end

        local char = player.Character
        if not (char and char.Parent) then return end
        local charState = SharedSherlock:find({"Binders", "getInstObj"}, {tag = "CharState", inst = char})
        self._maid:Add2(Promise.try(function()
            do
                local action = {
                    name = "fadeOut",
                    data = {
                        methods = {
                            {"fadeOut", {{duration = 0.5}}},
                            {"setText", {{Text = "You escaped...but for how long?",}}},
                        }
                    },
                }
                self.playerState:set(S.Session, "ScreenFader", action)
            end
            task.wait(2)
            do
                local action = {
                    name = "reset",
                }
                self.playerState:set(S.Session, "_Game", action)
            end
            do
                local action = {
                    name = "resetKeys",
                }
                charState:set(S.Session, "MapPuzzles", action)
            end
            do
                local action = {
                    name = "reset",
                }
                self.playerState:set(S.Session, "MapTokens", action)
            end
            do
                local action = {
                    name = "increment",
                    scoreType = S.FinishChapter,
                    timeType = "allTime",
                    value = 1,
                }
                self.playerState:set(S.Stores, "Scores", action)
            end
            do
                local action = {
                    name = "increment",
                    scoreType = S.FinishChapter1,
                    timeType = "allTime",
                    value = 1,
                }
                self.playerState:set(S.Stores, "Scores", action)
            end
            do
                local value = Calculators.calculate(self.playerState, "Money_1", 100 - 20 , S.FinishGame)
                local action = {
                    name = "Increment",
                    value = value,
                }
                self.playerState:set(S.Stores, "Money_1", action)
            end
            do
                local value = Calculators.calculate(self.playerState, "MoneyMonster", 4, S.FinishGame)
                local action = {
                    name = "Increment",
                    value = value,
                }
                self.playerState:set(S.Stores, "MoneyMonster", action)
            end

            local AwardBadgeSE = SharedSherlock:find({"Bindable", "sync"}, {root = self.player, signal = "AwardBadge"})
            if AwardBadgeSE then
                AwardBadgeSE:Fire(Data.Badges.Badges.nameToId["Winner"])
                AwardBadgeSE:Fire(Data.Badges.Badges.nameToId["Chapter 1"])
            end

            task.wait(5)
            char:PivotTo(workspace.Map.Chapters["1"].Teleports.BackToLobby:GetPivot())
            do
                local action = {
                    name = "fadeIn",
                    data = {
                        methods = {
                            {"fadeIn", {{duration = 0.5}}},
                        }
                    },
                }
                self.playerState:set(S.Session, "ScreenFader", action)
            end
        end))

    end)
end

function PlayerFinishGameS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.player, {
        events = {"FinishGame"},
        functions = {},
    }))
end

function PlayerFinishGameS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function PlayerFinishGameS:getFields()
    return WaitFor.GetAsync({
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
end

function PlayerFinishGameS:Destroy()
    self._maid:Destroy()
end

return PlayerFinishGameS