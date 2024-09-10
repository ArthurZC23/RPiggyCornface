local ServerStorage = game:GetService("ServerStorage")

local Data = ServerStorage.Data.SS.Data:Clone()
local AssetTypeEncoder = require(Data.Assets.AssetTypeCodec).encoder
local DressData = require(Data.MonsterSkins.DressTmp)

local dressDataArray = {}
for i = 36, 62 do
    table.insert(dressDataArray, tostring(i))
end

local function setBodyColors(humanoidDescription, bodyColors)
    if bodyColors.he then
        humanoidDescription.HeadColor = bodyColors.he
    end

    if bodyColors.lA then
        humanoidDescription.LeftArmColor = bodyColors.lA
    end

    if bodyColors.lL then
        humanoidDescription.LeftLegColor = bodyColors.lL
    end

    if bodyColors.rA then
        humanoidDescription.RightArmColor = bodyColors.rA
    end

    if bodyColors.rL then
        humanoidDescription.RightLegColor = bodyColors.rL
    end

    if bodyColors.to then
        humanoidDescription.TorsoColor = bodyColors.to
    end
end

local function setScales(humanoidDescription, scales)
    for scaleName, value in pairs(scales) do
        humanoidDescription[scaleName] = value
    end
end

local function setBodyParts(humanoidDescription, bodyParts)
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
        elseif asset.tId == AssetTypeEncoder.Head then
            humanoidDescription.Head = id
        end
    end
end

local function getAccessoryTable(accs)
    local accessoryTable = {}
    for id, data in ipairs(accs) do
        local assetId = tonumber(data.id)
        local Order = data.Order or 1
        table.insert(accessoryTable, {
            Order = Order,
            AssetId = assetId,
            AccessoryType = data.AccessoryType,
            tId = data.tId,
        })
    end
    return accessoryTable
end

for i, dressId in ipairs(dressDataArray) do
    local NextChar = workspace.Studio.Rigs.Monster.Next
    local Npc = NextChar:Clone()
    Npc.Parent = NextChar.Parent
    local cf0 = NextChar:GetPivot()
    Npc.Name = dressId
    Npc:PivotTo(cf0 - 8 * i * cf0.RightVector)
    local morphData = DressData.idData[dressId]
    
    local humanoid = Npc.Humanoid
    local humanoidDescription = Instance.new("HumanoidDescription")
    
    local accessoryTable = getAccessoryTable(morphData.assets)
    humanoidDescription:SetAccessories(accessoryTable, false)
    
    if morphData.classiClothes.shirt then
        humanoidDescription.Shirt = morphData.classiClothes.shirt
    end
    if morphData.classiClothes.pants then
        humanoidDescription.Pants = morphData.classiClothes.pants
    end
    if morphData.classiClothes.tshirt then
        humanoidDescription.GraphicTShirt = morphData.classiClothes.tshirt
    end
    setBodyColors(humanoidDescription, morphData.bodyColors)
    setBodyParts(humanoidDescription, morphData.bodyParts)
    setScales(humanoidDescription, morphData.scales)
    if morphData.face then
        humanoidDescription.Face = morphData.face
    end

    humanoid:ApplyDescription(humanoidDescription)

    task.wait(2)
end
