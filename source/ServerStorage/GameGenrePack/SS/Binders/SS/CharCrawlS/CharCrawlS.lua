local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local PlayerNetwork = Mod:find({"Network", "PlayerNetwork"})

local CharCrawlS = {}
CharCrawlS.__index = CharCrawlS
CharCrawlS.className = "CharCrawl"
CharCrawlS.TAG_NAME = CharCrawlS.className

function CharCrawlS.new(char)
    local self = {
        char = char,
        _maid = Maid.new(),
    }
    setmetatable(self, CharCrawlS)

    if not self:getFields() then return end
    self:createRemotes()
    self:setPlayerNetwork()
    self:handleCrawlRequest()
    self:handleCrawl()

    return self
end

function CharCrawlS:handleCrawlRequest()
    self.network:Connect(self.ToggleCrawlRE.OnServerEvent, function(player)
        local crawlState = self.charState:get(S.Session, "Crawl")
        do
            local action = {
                name = "set",
                value = not crawlState.on
            }
            self.charState:set(S.Session, "Crawl", action)
        end
    end)
end

function CharCrawlS:setSpeed(state)
    if state.on then
        local maid = self._maid:Add2(Maid.new(), "CrawlSpeed")
        local prop = self.charProps.props[self.charParts.humanoid]
        local property = "WalkSpeed"
        local cause = "Crawl"
        maid:Add2(function()
            prop:removeCause(property, cause)
        end)
        print("Set 8")
        prop:set(property, cause, 8)
    else
        print("Set 16")
        self._maid:Remove("CrawlSpeed")
    end
end

function CharCrawlS:handleCrawl()
    local function update(state)
        self:setSpeed(state)
    end
    self._maid:Add(self.charState:getEvent(S.Session, "Crawl", "set"):Connect(update))
    local state = self.charState:get(S.Session, "Crawl")
    update(state)
end

function CharCrawlS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"ToggleCrawl"},
        functions = {},
    }))
end

function CharCrawlS:setPlayerNetwork()
    self.network = self._maid:Add(PlayerNetwork.new(self.player))
end

function CharCrawlS:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            if not self.player then return end
            local bindersData = {
                {"CharState", self.char},
                {"CharParts", self.char},
                {"CharProps", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.charCoreAnimations = self.charCoreAnimationsR15

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=1
    })
    return ok
end

function CharCrawlS:Destroy()
    self._maid:Destroy()
end

return CharCrawlS