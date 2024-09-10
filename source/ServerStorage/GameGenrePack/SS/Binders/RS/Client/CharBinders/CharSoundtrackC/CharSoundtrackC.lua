local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local CharSoundtrackC = {}
CharSoundtrackC.__index = CharSoundtrackC
CharSoundtrackC.className = "CharSoundtrack"
CharSoundtrackC.TAG_NAME = CharSoundtrackC.className

function CharSoundtrackC.new(char)
    local isLocalChar = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharSoundtrackC)

    if not self:getFields() then return end
    self:handleRegionSoundtrack()

    return self
end

local Bach = Mod:find({"Bach", "Bach"})
function CharSoundtrackC:handleRegionSoundtrack()
    local function playSoundtrack(state, action)
        local soundtrackName = action.soundtrackName
        local soundtracks = workspace.Audio.Soundtracks[soundtrackName]:GetChildren()
        Bach:play(
            soundtracks[Random.new():NextInteger(1, #soundtracks)],
            Bach.SoundTypes.Soundtrack,
            {
                soundtrackType = soundtrackName,
                fadeIn = action.fadeIn,
                fadeOut = action.fadeOut,
            }
        )
    end
    self._maid:Add2(self.charState:getEvent(S.Session, "Regions", "PlaySoundtrack"):Connect(playSoundtrack))
    local regionState = self.charState:get(S.Session, "Regions")
    for regionName in pairs(regionState.regions) do
        local eventsNames = Data.Regions.Regions.addRegionsEvents[regionName]
        if eventsNames["PlaySoundtrack"] then
            playSoundtrack(nil, eventsNames["PlaySoundtrack"])
            break
        end
    end
end

function CharSoundtrackC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            self.player = Players:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {
                {"PlayerState", self.player},
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

function CharSoundtrackC:Destroy()
    self._maid:Destroy()
end

return CharSoundtrackC