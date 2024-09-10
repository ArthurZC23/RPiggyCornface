local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})

local module = {}

local AssetsUtils = Mod:find({"Assets", "Shared", "Utils"})

local Promise = Mod:find({"Promise", "Promise"})
local Players = game:GetService("Players")

local S = Data.Strings.Strings
function module.getRobloxAvatar(playerState, kwargs)
    local player = playerState
    kwargs = kwargs or {}
    local function _fetch()
        -- https://create.roblox.com/docs/reference/engine/classes/Players#GetCharacterAppearanceInfoAsync
        return Promise.new(function(resolve, reject)
            local ok, data = pcall(function()
                local data = Players:GetCharacterAppearanceInfoAsync(player.UserId)
                return data
            end)
            if ok then
                resolve(data)
            else
                local err = data
                reject(err)
            end
        end)
    end
    return
        Promise.retryWithDelay(_fetch, 4, 5)
        :andThen(function(data)
            local _realData = {
                assets = {},
                bodyColors = {
                    lA = data.bodyColors.leftArmColorId,
                    lL = data.bodyColors.leftLegColorId,
                    rA = data.bodyColors.rightArmColorId,
                    rL = data.bodyColors.rightLegColorId,
                    to = data.bodyColors.torsoColorId,
                    he = data.bodyColors.headColorId,
                },
            }
            for i, assetData in ipairs(data.assets) do
                local tId
                if assetData.assetType and assetData.assetType.id then
                    tId = tostring(assetData.assetType.id)
                end
                _realData.assets[tostring(assetData.id)] = {
                    tId = tId,
                }
            end
            do
                local action = {
                    name = "setRobloxAvatar",
                    value = _realData,

                }
                playerState:set(S.Session, "App", action)
            end

        end)
end

function module.parseStoreAssets(storeAssets)
    local assets = {
        accs = {},
        bodyParts = {},
    }
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    for id, asset in pairs(storeAssets) do
        asset.id = id
        if asset.tId == AssetTypeEncoder.Shirt then
            assets.shirt = asset
        elseif asset.tId == AssetTypeEncoder.Pants then
            assets.pants = asset
        elseif asset.tId == AssetTypeEncoder.Face then
            assets.face = asset
        elseif asset.tId == AssetTypeEncoder.Head or asset.tId == AssetTypeEncoder.DynamicHead then -- or asset.tId == AssetTypeEncoder.DynamicHead then -- Don't accept dynamic head for now
            assets.head = asset
        elseif
            AssetsUtils.isAccessory(asset.tId)
            or AssetsUtils.isHair(asset.tId)
        then
            assets.accs[id] = asset
        elseif AssetsUtils.isBodyPart(asset.tId) then
            assets.bodyParts[id] = asset
        end
    end
    return assets
end

function module.getAccessoryTable(accs)
    local accessoryTable = {}
    for id, data in pairs(accs) do
        local assetId = tonumber(data.id)
        local assetTypeId = data.tId
        local AccessoryType = Data.Appearance.Accessories.AccessoryCodec.decoder[assetTypeId]
        local Order = data.Order or 1
        table.insert(accessoryTable, {
            Order = Order,
            AssetId = assetId,
            AccessoryType = Enum.AccessoryType[AccessoryType],
        })
    end
    return accessoryTable
end

function module.setBodyColors(humanoidDescription, bodyColors)
    local headColorId = bodyColors.he
    local headBrickColor = BrickColor.new(headColorId)
    humanoidDescription.HeadColor = Color3.new(headBrickColor.r, headBrickColor.g, headBrickColor.b)

    local leftArmColorId = bodyColors.lA
    local leftArmBrickColor = BrickColor.new(leftArmColorId)
    humanoidDescription.LeftArmColor = Color3.new(leftArmBrickColor.r, leftArmBrickColor.g, leftArmBrickColor.b)

    local leftLegColorId = bodyColors.lL
    local leftLegBrickColor = BrickColor.new(leftLegColorId)
    humanoidDescription.LeftLegColor = Color3.new(leftLegBrickColor.r, leftLegBrickColor.g, leftLegBrickColor.b)

    local rightArmColorId = bodyColors.rA
    local rightArmBrickColor = BrickColor.new(rightArmColorId)
    humanoidDescription.RightArmColor = Color3.new(rightArmBrickColor.r, rightArmBrickColor.g, rightArmBrickColor.b)

    local rightLegColorId = bodyColors.rL
    local rightLegBrickColor = BrickColor.new(rightLegColorId)
    humanoidDescription.RightLegColor = Color3.new(rightLegBrickColor.r, rightLegBrickColor.g, rightLegBrickColor.b)

    local torsoColorId  = bodyColors.to
    local torsoBrickColor = BrickColor.new(torsoColorId)
    humanoidDescription.TorsoColor = Color3.new(torsoBrickColor.r, torsoBrickColor.g, torsoBrickColor.b)
end

function module.setBodyParts(humanoidDescription, bodyParts)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    for id, asset in pairs(bodyParts) do
        if asset.tId == AssetTypeEncoder.Torso then
            humanoidDescription.Torso = id
        elseif asset.tId == AssetTypeEncoder.RightArm then
            humanoidDescription.RightArm = id
        elseif asset.tId == AssetTypeEncoder.LeftArm then
            humanoidDescription.LeftArm = id
        elseif asset.tId == AssetTypeEncoder.RightLeg then
            humanoidDescription.RightLeg = id
        elseif asset.tId == AssetTypeEncoder.LeftLeg then
            humanoidDescription.LeftLeg = id
        end
    end
end

local TableUtils = Mod:find({"Table", "Utils"})
function module.convertStoreToHumanoiDescription(appData)
    local humanoidDescription = Instance.new("HumanoidDescription")
    local storeAssets = TableUtils.deepCopy(appData.assets)
    local assets = module.parseStoreAssets(storeAssets)

    local accessoryTable = module.getAccessoryTable(assets.accs)
    humanoidDescription:SetAccessories(accessoryTable, false)

    module.setBodyColors(humanoidDescription, appData.bodyColors)
    module.setBodyParts(humanoidDescription, assets.bodyParts)

    if assets.shirt then
        humanoidDescription.Shirt = assets.shirt.id
    end
    if assets.pants then
        humanoidDescription.Pants = assets.pants.id
    end
    if humanoidDescription.Pants == 0 then
        humanoidDescription.Pants = 398633812
    end

    if assets.face then
        humanoidDescription.Face = assets.face.id
    end
    if assets.head then
        humanoidDescription.Head = assets.head.id
    end

    return humanoidDescription
end

return module