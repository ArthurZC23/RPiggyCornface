local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Data = script:FindFirstAncestor("Data")
local S = require(Data.Strings.Strings)
local GpData = require(Data.GamePasses.GamePasses)

local module = {}

module.playerMonster = {
    timeMoneyMonsterRatio = 60,
    money_1KillRatio = 5,
}

-- Uncommon range
-- 30-150

-- Rare range
-- 160 - 600

-- Legendary range
-- 600 - 1800

-- Godly range
-- 1800 - 5000

-- if RunService:IsStudio() then
--     module.playerMonster.timeMoneyMonsterRatio = 10
-- end

module.idData = {
    ["1"] = {
        rarity = "Uncommon",
        name = "Cornface",
        viewName = "Cornface",
        rewards = {
            shop = {
                _type = "free",
            },
        },
    },
    ["2"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "White",
        viewName = "White",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 30,
            },
        },
    },
    ["3"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Green",
        viewName = "Green",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 30,
            },
        },
    },
    ["4"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Blue",
        viewName = "Blue",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 40,
            },
        },
    },
    ["5"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Pink",
        viewName = "Pink",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 50,
            },
        },
    },
    ["6"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Brown",
        viewName = "Brown",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 60,
            },
        },
    },
    ["7"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Black",
        viewName = "Black",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 70,
            },
        },
    },
    ["8"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Red",
        viewName = "Red",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 80,
            },
        },
    },
    ["9"] = {
        rarity = "Uncommon",
        colorSwap = true,
        name = "Purple",
        viewName = "Purple",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 90,
            },
        },
    },
    ["10"] = {
        rarity = "Rare",
        name = "Noob",
        viewName = "Noob",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 110,
            },
        },
    },
    ["11"] = {
        rarity = "Rare",
        name = "Bacon",
        viewName = "Bacon",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 130,
            },
        },
    },
    ["12"] = {
        rarity = "Rare",
        name = "SilverDip",
        viewName = "Silver Dip",
        rewards = {
            shop = {
                _type = "Gamepass",
                gpId = GpData.nameToData[S.MetalDipPack].id,
            },
        },
    },
    ["13"] = {
        rarity = "Rare",
        name = "GoldDip",
        viewName = "Gold Dip",
        rewards = {
            shop = {
                _type = "Gamepass",
                gpId = GpData.nameToData[S.MetalDipPack].id,
            },
        },
    },
    ["14"] = {
        rarity = "Rare",
        name = "BronzeDip",
        viewName = "Bronze Dip",
        rewards = {
            shop = {
                _type = "Gamepass",
                gpId = GpData.nameToData[S.MetalDipPack].id,
            },
        },
    },
    ["15"] = {
        rarity = "Legendary",
        name = "Glitch",
        viewName = "Glitch",
        rewards = {
            shop = {
                _type = "NotShopReward",
                viewRewardType = "Spin Wheel Legendary Skin",
            },
        },
        LayoutOrder = -55,
        tags = {

        }
    },
    ["16"] = {
        rarity = "Rare",
        name = "TwoEyes",
        viewName = "2 Eyes",
        rewards = {
            shop = {
                _type = "Money",
                moneyType = S.Money_1,
                price = 150,
            },
        },
    },
    ["17"] = {
        rarity = "Legendary",
        name = "Rainbow",
        viewName = "Rainbow",
        rewards = {
            shop = {
                _type = "Gamepass",
                gpId = GpData.nameToData[S.RainbowMonsterSkin].id,
            },
        },
        LayoutOrder = -54,
        tags = {
            "RainbowMonsterSkin",
        }
    },
}

module.nameData = {}

for id, data in pairs(module.idData) do

    data.monsterModel = ReplicatedStorage.Assets.Monsters.Monsters[id]--:Clone()
    data.monsterModel:SetAttribute("skinId", id)
    data.monsterModel.Humanoid.RequiresNeck = false

    local Toucher = ReplicatedStorage.Assets.Parts.MonsterToucher:Clone()
    Toucher:PivotTo(data.monsterModel.HumanoidRootPart.SRefMonsterToucher.WorldCFrame)
    Toucher.WeldConstraint.Part1 = data.monsterModel.HumanoidRootPart
    Toucher.Name = "Toucher"
    Toucher.Parent = data.monsterModel
    data.monsterModel.Toucher:SetAttribute("transpDefault", 1)


    -- data.camouflageModel = ReplicatedStorage.Assets.Monsters.Monsters[id]:Clone()
    -- data.camouflageModel:ScaleTo(0.46)
    -- data.camouflageModel.HumanoidRootPart:Destroy()
    -- data.camouflageModel.PrimaryPart = data.camouflageModel.Body
    -- data.camouflageModel.Body.PivotOffset = CFrame.new(0, -1.799, 0)
    -- data.camouflageModel.Humanoid:Destroy()
    -- for i, desc in ipairs(data.camouflageModel:GetDescendants()) do
    --     if not desc:IsA("Motor6D") then continue end
    --     local WeldConstraint = Instance.new("WeldConstraint")
    --     WeldConstraint.Name = desc.Name
    --     WeldConstraint.Part0 = desc.Part0
    --     WeldConstraint.Part1 = desc.Part1
    --     WeldConstraint.Parent = desc.Parent
    --     desc:Destroy()
    -- end
    -- data.camouflageModel.Parent = ReplicatedStorage.Assets.Monsters.Camouflages

    -- data.model = data.camouflageModel -- I need the model key for gui code
    -- for _, desc in ipairs(data.model:GetDescendants()) do
    --     if desc:IsA("BasePart")then
    --         desc.Anchored = false
    --         desc.CanCollide = false
    --         desc.CanQuery = false
    --         desc.CanTouch = false
    --         desc.Massless = true
    --         desc.CastShadow = false
    --         if desc:GetAttribute("Camouflage") == nil then
    --             desc:SetAttribute("Camouflage", true)
    --         end
    --     elseif desc:IsA("Decal") then
    --         if desc:GetAttribute("Camouflage") == nil then
    --             desc:SetAttribute("Camouflage", true)
    --         end
    --     elseif desc:IsA("ParticleEmitter") then
    --         desc.Enabled = false
    --     end
    -- end


    data.model = data.monsterModel

    for i, desc in ipairs(data.monsterModel:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = false
            if desc.Parent ~= data.monsterModel then
                if desc:GetAttribute("transpDefault") == nil then
                    desc:SetAttribute("transpDefault", 0)
                end
                desc.CanCollide = false
                desc.Massless = true
                desc.CanTouch = false
                desc.CanQuery = false
                desc.CastShadow = false
            end
        elseif desc:IsA("Decal") then
            if desc:GetAttribute("transpDefault") == nil then
                desc:SetAttribute("transpDefault", 0)
            end
        end
    end

    data.vpf = data.vpf or {}
    data.vpf.CameraAngles = data.vpf.CameraAngles or Vector3.new(0, 0, 0)
    data.vpf.CameraPosition = data.vpf.CameraPosition or Vector3.new(0.5, 0.5, -7)
    data.vpf.CameraPositionOffset = data.vpf.CameraPositionOffset or Vector3.new(0, 2.5, 0)
    data.id = id
    data.LayoutOrder = data.LayoutOrder or tonumber(-id)
    module.nameData[data.name] = data
end

return module