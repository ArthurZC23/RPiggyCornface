local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local module = {}

function module.getCharType(char)
    local charType = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            if CollectionService:HasTag(char, "PlayerCharacter") then
                return "PCharacter"
            elseif CollectionService:HasTag(char, "Npc") then
                return "Npc"
            elseif CollectionService:HasTag(char, "PlayerDummy") then
                return "PlayerDummy"
            elseif CollectionService:HasTag(char, "DummyCustomization") then
                return "DummyCustomization"
            elseif CollectionService:HasTag(char, "AttackDummy") then
                return "AttackDummy"
            elseif CollectionService:HasTag(char, "CutsceneDummy") then
                return "CutsceneDummy"
            end
        end,
        keepTrying=function()
            return char.Parent
        end,
        cooldown = 0.1,
    })
    return charType
end
------------
function module.isAnyChar(char)
    return
        CollectionService:HasTag(char, "PlayerCharacter") or
        CollectionService:HasTag(char, "Npc") or
        CollectionService:HasTag(char, "PlayerDummy")
end
function module.isNpc(char)
    local charType = module.getCharType(char)
    return charType == "Npc"
end

function module.isPChar(char)
    local charType = module.getCharType(char)
    return charType == "PCharacter"
end

if RunService:IsClient() then
    local localPlayer = Players.LocalPlayer
    function module.isLocalChar(char)
        local charType = module.getCharType(char)
        if charType ~= "PCharacter" then return end
        local plr = PlayerUtils:GetPlayerFromCharacter(char)
        -- print("isLocalChar", char:GetFullName(), plr, localPlayer)
        return localPlayer == plr, plr
    end

    function module.isOtherPChar(char)
        local charType = module.getCharType(char)
        if charType == "Npc" then return end
        local plr = PlayerUtils:GetPlayerFromCharacter(char)
        return localPlayer ~= plr
    end
end


return module