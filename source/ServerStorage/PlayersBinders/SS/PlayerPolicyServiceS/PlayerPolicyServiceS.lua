local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})

local PlayerPolicyServiceS = {}
PlayerPolicyServiceS.__index = PlayerPolicyServiceS
PlayerPolicyServiceS.className = "PlayerPolicyService"
PlayerPolicyServiceS.TAG_NAME = PlayerPolicyServiceS.className

function PlayerPolicyServiceS.new(player)
    local self = {
        player = player,
        _maid = Maid.new(),
    }
    setmetatable(self, PlayerPolicyServiceS)

    if not self:getFields() then return end
    self:getPlayerPolicy()

    return
end

function PlayerPolicyServiceS:getPlayerPolicy()
    local function GetPolicyInfo()
        return PolicyService:GetPolicyInfoForPlayerAsync(self.player)
    end

    Promise.retryWithDelay(GetPolicyInfo, 10, 10)
    :andThen(function(res)
        -- print("AreAdsAllowed: ", res.AreAdsAllowed)
        -- if RunService:IsStudio() then
        --     res.AreAdsAllowed = false
        -- end
        local links = {}
        for _, link in ipairs(res.AllowedExternalLinkReferences) do
            links[link] = true
        end
        do
            local action = {
                name = "setPoliceService",
                value = {
                    AreAdsAllowed = res.AreAdsAllowed,
                    ArePaidRandomItemsRestricted = res.ArePaidRandomItemsRestricted,
                    AllowedExternalLinkReferences = links,
                    IsEligibleToPurchaseSubscription = res.IsEligibleToPurchaseSubscription,
                    IsPaidItemTradingAllowed = res.IsPaidItemTradingAllowed,
                    IsSubjectToChinaPolicies = res.IsSubjectToChinaPolicies,
                },
            }
            self.playerState:set(S.Session, "PolicyService", action)
        end
        return
    end)
    :catch(function(err)
        warn(tostring(err))
    end)
end

function PlayerPolicyServiceS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.player.Parent
        end,
    })
    return ok
end

function PlayerPolicyServiceS:Destroy()
    self._maid:Destroy()
end

return PlayerPolicyServiceS