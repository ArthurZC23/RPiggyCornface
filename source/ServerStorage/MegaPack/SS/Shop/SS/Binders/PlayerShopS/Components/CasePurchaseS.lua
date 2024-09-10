local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Sampler = Mod:find({"Math", "Sampler"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local TableUtils = Mod:find({"Table", "Utils"})

local CasePurchaseS = {}
CasePurchaseS.__index = CasePurchaseS
CasePurchaseS.className = "PlayerShop"

function CasePurchaseS.new(playerShop)
    local self = {
        _maid = Maid.new(),
        playerShop = playerShop,
        samplers = {
            rarity = Sampler.new(),
        },
    }
    setmetatable(self, CasePurchaseS)

    if not self:getFields() then return end
    self:createRemotes()

    return self
end

function CasePurchaseS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.playerShop.player, {
        events = {"OpenCase"},
        functions = {},
    }))
end


function CasePurchaseS:sampleRarity(rarityOdds)
    local rarityArray, oddsArray = TableUtils.breakKeyValInSyncedArrays(rarityOdds)
    -- self.samplers.rarity:testSampler(rarityArray, oddsArray)
    local sampleIdx = self.samplers.rarity:sampleDiscrete(oddsArray)
    local rarity = rarityArray[sampleIdx]
    return rarity
end

function CasePurchaseS:sampleAsset(caseData, rarity)
    local assetsOfGivenRarity = caseData.assetsIdsByRarity[rarity]
    local assetId = TableUtils.sampleArray(assetsOfGivenRarity)
    return assetId
end

function CasePurchaseS:sampleCase(caseData)
    local rarityOdds = TableUtils.deepCopy(caseData.raritiesOdds)
    local rarity = self:sampleRarity(rarityOdds)
    local assetId = self:sampleAsset(caseData, rarity)
    return assetId
end

function CasePurchaseS:getCaseAsset(caseData)
    local assetId = self:sampleCase(caseData)
    self[("give%sToPlayer"):format(caseData.assetType)](self, assetId)
    self.OpenCaseRE:FireClient(self.playerShop.player, caseData.id, assetId)
end

function CasePurchaseS:_getCaseAssetDebug(caseData)
    assert(RunService:IsStudio(), "This can only run on studio!")
    warn("Running _getCaseAssetDebug")
    for _=1, 1e4 do
        local assetId = self:sampleCase(caseData)
        self[("give%sToPlayer"):format(caseData.assetType)](self, assetId)
    end
end

function CasePurchaseS:giveCharSkinToPlayer(assetId)
    local styleId = assetId.styleId
    local skinId = assetId.skinId

    local action = {
        name = "addSkins",
        data = {
            [styleId] = {
                [skinId] = 1,
            },
        }
    }
    self.playerShop.playerState:set(S.Stores, "Skins", action)
end

function CasePurchaseS:giveWeaponSkinToPlayer(assetId)
    local wId = assetId.id

    local action = {
        name = "addWSkins",
        data = {
            [wId] = 1,
        }
    }
    self.playerShop.playerState:set(S.Stores, "WSkins", action)
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CasePurchaseS:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local BinderUtils = Mod:find({"Binder", "Utils"})
            local bindersData = {}
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            local remotes = {}
            local root
            if not BinderUtils.addRemotesToTable(self, root, remotes) then return end
            return true
        end,
        keepTrying=function()
            return self.playerShop.player.Parent
        end,
        cooldown=nil
    })
    return ok
end


function CasePurchaseS:Destroy()
    self._maid:Destroy()
end

return CasePurchaseS