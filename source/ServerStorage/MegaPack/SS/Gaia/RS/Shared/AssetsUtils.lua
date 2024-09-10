local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local module = {}

function module.isClothing(tId)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    return
        tId == AssetTypeEncoder.Shirt
        or tId == AssetTypeEncoder.Pants
end

function module.isBody(tId)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    return
        tId == AssetTypeEncoder.Face
        or tId == AssetTypeEncoder.DynamicHead
        or tId == AssetTypeEncoder.HairAccessory
end

function module.isBodyPart(tId)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    return
        tId == AssetTypeEncoder.RightArm
        or tId == AssetTypeEncoder.LeftArm
        or tId == AssetTypeEncoder.RightLeg
        or tId == AssetTypeEncoder.LeftLeg
        or tId == AssetTypeEncoder.Torso
end

function module.isHair(tId)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    return
        tId == AssetTypeEncoder.HairAccessory
end

function module.isFace(tId)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    return
        tId == AssetTypeEncoder.Face
        or tId == AssetTypeEncoder.DynamicHead
end


function module.isAccessory(tId)
    local AssetTypeEncoder = Data.Assets.AssetTypeCodec.encoder
    return
        tId == AssetTypeEncoder.Hat
        or tId == AssetTypeEncoder.FaceAccessory
        or tId == AssetTypeEncoder.NeckAccessory
        or tId == AssetTypeEncoder.ShoulderAccessory
        or tId == AssetTypeEncoder.FrontAccessory
        or tId == AssetTypeEncoder.BackAccessory
        or tId == AssetTypeEncoder.WaistAccessory
        -- or tId == AssetTypeEncoder.HairAccessory This is a body part
end

function module._setModelVpf(gui, assetType, kwargs)
    local vpf = gui
    local model = module.getModel(assetType, kwargs)
    model.Name = "Model"
    model.Parent = vpf
    module.setVpfCamera(vpf, assetType, kwargs.cameraProps)
    CollectionService:AddTag(vpf, "Vpf")
end

function module.setModel(gui, assetType, kwargs)
    if
        assetType == "MonsterSkin"
        or assetType == "Item"
    then
        module._setModelVpf(gui, assetType, kwargs)
    else
        error("")
    end
end

function module.setVpfCamera(vpf, assetType, kwargs)
    vpf.CameraAngles.Value = kwargs.CameraAngles
    vpf.CameraPosition.Value = kwargs.CameraPosition
    vpf.CameraPositionOffset.Value = kwargs.CameraPositionOffset
end

function module.getModel(assetType, kwargs)
    local data = module.getAssetData(assetType, kwargs)
    local model = data.model:Clone()
    return model
end

local Promise = Mod:find({"Promise", "Promise"})
local MarketplaceService = game:GetService("MarketplaceService")
function module.getMarketplaceAssetData(kwargs)
    local state = kwargs.playerState:get(S.LocalSession, "AvatarGui")
    local assetsCache = state.assetsCache
    local assetId = kwargs.assetId
    if assetsCache[assetId] then
        return Promise.resolve(assetsCache[assetId])
    end
    return Promise.new(function(resolve, reject)
        local success, result = pcall(function()
			return MarketplaceService:GetProductInfo(assetId)
		end)
		if success then
			warn("Add to cache")
			resolve(result)
		else
			reject(result)
		end
    end)
end

function module.getAssetData(assetType, kwargs)
    if assetType == "MonsterSkin" then
        local assetData = Data.MonsterSkins.MonsterSkins.idData[kwargs.id]
        return assetData
    elseif assetType == "Item" then
        local assetData = Data.Items.Items.idData[kwargs.id]
        return assetData
    else
        error(("Asset type %s not valid."):format(assetType))
    end
end

function module.hasAsset(playerState, assetType, assetId)
    error("Implement")
end

return module