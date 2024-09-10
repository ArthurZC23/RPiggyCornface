local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local Data = Mod:find({"Data", "Data"})
local TableUtils = Mod:find({"Table", "Utils"})
local CircularArray = Mod:find({"DataStructures", "Array", "Circular"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Promise = Mod:find({"Promise", "Promise"})
local GaiaShared = Mod:find({"Gaia", "Shared"})

local UgcShopS = {}
UgcShopS.__index = UgcShopS
UgcShopS.className = "UgcShop"
UgcShopS.TAG_NAME = UgcShopS.className

function UgcShopS.new(ugcShop)
    local self = {
        _maid = Maid.new(),
        ugcShop = ugcShop,
    }
    setmetatable(self, UgcShopS)

    self:setDummies()
    self:start()

    return self
end

local function _fetchAsset(uri)
    return function()
        return Promise.new(function(resolve, reject)
            local ok, model = pcall(function()
                local model = InsertService:LoadAsset(tonumber(uri))
                return model
            end)
            if ok then
                resolve(model)
            else
                local err = model
                reject(err)
            end
        end)
    end
end

function UgcShopS:setDummies()
    for _, dummy in pairs(self.ugcShop.Dummies:GetChildren()) do
        local hrp = dummy.HumanoidRootPart
        hrp.Anchored = true

        GaiaShared.create("ProximityPrompt", {
            Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton,
            HoldDuration = 0.25,
            MaxActivationDistance = 10,
            ActionText = "Purchase UGC",
            RequiresLineOfSight = false,
            Parent = hrp.RootAttachment,
        })
    end
end

function UgcShopS:loadAccessoryIntoDummy(i, ugcUri, accessory)
    local maid = self._maid:Add2(Maid.new(), ("dummy%s"):format(i))
    local dummy = self.ugcShop.Dummies[i]
    local humanoid = dummy.Humanoid
    maid:Add(function()
        humanoid:RemoveAccessories()
    end)
    humanoid:AddAccessory(accessory)

    local hrp = dummy.HumanoidRootPart
    local pp = hrp.RootAttachment.ProximityPrompt
    maid:Add(pp.Triggered:Connect(function(player)
        do
            local ok, hasAsset = pcall(function()
                return MarketplaceService:PlayerOwnsAsset(player, tonumber(ugcUri))
            end)

            if not ok then
                warn(hasAsset)
                return
            end

            if hasAsset then
                warn("You already own this UGC item.")
                return
            end
        end

        MarketplaceService:PromptPurchase(player, tonumber(ugcUri), false)
    end))

    local gui = dummy:FindFirstChild("Gui")
    if gui then
        local text = gui.SurfaceGui.TextLabel
        maid:Add(function()
            text.Text = ""
        end)
        text.Text = accessory.Name
    end
end

local Sampler = Mod:find({"Math", "Sampler"})
function UgcShopS:start()
    local ugcData = Data.Appearance.UGC.UGC.ugc
    local idxArray = {}
    for id, data in pairs(ugcData) do
        table.insert(idxArray, {id, data})
    end
    local sampler = Sampler.new()
    sampler:shuffle(idxArray)
    local cIdxArray = CircularArray.new(idxArray)

    local numSamples = #self.ugcShop.Dummies:GetChildren()

    local ugcs = {}
    for i=1, numSamples do
        local id, v = cIdxArray:next()
        ugcs[i] = v[2]["uri"]
    end
    -- if RunService:IsStudio() then
    --     TableUtils.print(ugcs)
    -- end
    for i, ugcUri in ipairs(ugcs) do
        Promise.retryWithDelay(_fetchAsset(ugcUri), 3, 10)
        :andThen(function(model)
            local accessory = model:FindFirstChildOfClass("Accessory")
            if not accessory then warn("No accessory") end
            self:loadAccessoryIntoDummy(i, ugcUri, accessory)
        end)
        :catchAndPrint()
    end

    -- local cd = 100 * 60
    -- if RunService:IsStudio() then
    --     cd = 15
    -- end

    -- BigBen.every(cd, "Heartbeat", "time_", true):Connect(function()
    --     local ugcs = {}
    --     for i=1, numSamples do
    --         local id, v = cIdxArray:next()
    --         ugcs[i] = v[2]["uri"]
    --     end
    --     -- if RunService:IsStudio() then
    --     --     TableUtils.print(ugcs)
    --     -- end
    --     for i, ugcUri in ipairs(ugcs) do
    --         Promise.retryWithDelay(_fetchAsset(ugcUri), 3, 10)
    --         :andThen(function(model)
    --             local accessory = model:FindFirstChildOfClass("Accessory")
    --             if not accessory then warn("No accessory") end
    --             self:loadAccessoryIntoDummy(i, ugcUri, accessory)
    --         end)
    --         :catchAndPrint()
    --     end
    -- end)
end

function UgcShopS:Destroy()
    self._maid:Destroy()
end

return UgcShopS