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
    }
    setmetatable(self, CharCrawlC)

    if not self:getFields() then return end
    self:loadAnimations()
    self:handleCrawl()

    return self
end

function CharCrawlC:loadAnimations()
    local coreAnimations = Data.Animations.Animations.R15.Crawl
    for _, animation in pairs(coreAnimations) do
        self.charCoreAnimations:LoadAnimation(animation)
    end
end

function CharCrawlC:handleCrawl()
    local function update(state)
        if state.on then
            local coreAnimations = Data.Animations.Animations.R15.Crawl
            local maid = self._maid:Add2(Maid.new(), "CrawlAnimation")
            local tbl = {
                {"idle", "Idle", 10},
                {"walk", "Walk", 10},
                {"run", "Run", 10},
            }
            maid:Add(function()
                if not self.char.Parent then return end
                for _, data in ipairs(tbl) do
                    local coreAnim = data[1]
                    local poseStyle = "Default"
                    local weight = data[3]
                    local CoreAnimationsData = Data.Animations[("CoreAnimations%s"):format("R15")]
                    self.charCoreAnimations:setPoseAnimations(
                        coreAnim,
                        poseStyle,
                        CoreAnimationsData.defaultCoreAnimations[coreAnim]
                    )
                end
            end)
            for _, data in ipairs(tbl) do
                local coreAnim = data[1]
                local animKey = data[2]
                local poseStyle = coreAnimations[animKey]
                local weight = data[3]
                self.charCoreAnimations:setPoseAnimations(
                    coreAnim,
                    poseStyle,
                    {
                        {
                            id = coreAnimations[animKey].AnimationId,
                            weight = weight,
                        },
                    }
                )
            end
        else
            self._maid:Remove("CrawlAnimation")
        end
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
                {"CharCoreAnimationsR15", self.char},
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

function CharCrawlC:Destroy()
    self._maid:Destroy()
end

return CharCrawlC