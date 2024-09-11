local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local CharCrawlC = {}
CharCrawlC.__index = CharCrawlC
CharCrawlC.className = "CharCrawl"
CharCrawlC.TAG_NAME = CharCrawlC.className

function CharCrawlC.new(char)
    local isLocalChar, player = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        player = player,
        char = char,
        _maid = Maid.new(),
        controllers = {},
        views = {},
    }
    setmetatable(self, CharCrawlC)

    if not self:getFields() then return end
    self:handleCrawl()

    return self
end

function CharCrawlC:handleCrawl()
    local function update(state)
        warn("Finish")
    end
    self._maid:Add(self.charState:getEvent(S.LocalSession, "Crawl", "set"):Connect(update))
    local state = self.charState:get(S.LocalSession, "Crawl")
    update(state)
end

function CharCrawlC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharState", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=1
    })
    return ok
end

function CharCrawlC:Destroy()
    self._maid:Destroy()
end

return CharCrawlC