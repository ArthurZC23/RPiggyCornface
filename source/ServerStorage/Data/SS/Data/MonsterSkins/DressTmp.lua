--[[
    Humanoid Description data to check outfits in Studio
]]

local Data = script:FindFirstAncestor("Data")
local AssetTypeEncoder = require(Data.Assets.AssetTypeCodec).encoder

local coreRunAnimations = {
    10921336997, --"1113750642",
    "1113751657",
    "1090130630",
    "837023444",
    "837023892",
    "734325948",
    "619528716",
    "973766674",
    "5319900634",
    "619512153",
    "619522386",
    "892265784",
}

local module = {}

module.idData = {
    ["30"] = {
        spawnToTest = true,
        name = "30",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            -- shirt = 223768622,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            ["14498289777"] = {
                tId = AssetTypeEncoder.Torso,
            },
            -- RightArm
            ["14498289785"] = {
                tId = AssetTypeEncoder.RightArm,
            },
            -- LeftArm
            ["14498289877"] = {
                tId = AssetTypeEncoder.LeftArm,
            },
            -- LeftLeg
            ["14498289824"] = {
                tId = AssetTypeEncoder.LeftLeg,
            },
            -- RightLeg
            ["14498289771"] = {
                tId = AssetTypeEncoder.RightLeg,
            },
        },
    },
    ["31"] = {
        spawnToTest = true,
        name = "31",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            -- shirt = 223768622,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            ["14731377894"] = {
                tId = AssetTypeEncoder.RightArm,
            },
            -- LeftArm
            ["14731377875"] = {
                tId = AssetTypeEncoder.LeftArm,
            },
            -- LeftLeg
            ["14731377938"] = {
                tId = AssetTypeEncoder.LeftLeg,
            },
            -- RightLeg
            ["14731384498"] = {
                tId = AssetTypeEncoder.RightLeg,
            },
        },
    },
    ["32"] = {
        spawnToTest = true,
        name = "32",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            -- shirt = 223768622,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            ["17788567438"] = {
                tId = AssetTypeEncoder.RightArm,
            },
            -- LeftArm
            ["17788567526"] = {
                tId = AssetTypeEncoder.LeftArm,
            },
            -- LeftLeg
            ["17788567441"] = {
                tId = AssetTypeEncoder.LeftLeg,
            },
            -- RightLeg
            ["17788567443"] = {
                tId = AssetTypeEncoder.RightLeg,
            },
        },
    },
    ["33"] = {
        spawnToTest = true,
        name = "33",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            -- shirt = 223768622,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            ["15527831669"] = {
                tId = AssetTypeEncoder.RightArm,
            },
            -- LeftArm
            ["15527836067"] = {
                tId = AssetTypeEncoder.LeftArm,
            },
            -- LeftLeg
            ["15527827578"] = {
                tId = AssetTypeEncoder.LeftLeg,
            },
            -- RightLeg
            ["15527827600"] = {
                tId = AssetTypeEncoder.RightLeg,
            },
        },
    },
    ["34"] = {
        spawnToTest = true,
        name = "34",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            -- shirt = 223768622,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            ["2510270282"] = {
                tId = AssetTypeEncoder.RightArm,
            },
            -- LeftArm
            ["2510260686"] = {
                tId = AssetTypeEncoder.LeftArm,
            },
            -- LeftLeg
            ["2510269155"] = {
                tId = AssetTypeEncoder.LeftLeg,
            },
            -- RightLeg
            ["2510271496"] = {
                tId = AssetTypeEncoder.RightLeg,
            },
        },
    },
    ["35"] = {
        spawnToTest = true,
        name = "35",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            -- shirt = 223768622,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            ["4637120775"] = {
                tId = AssetTypeEncoder.RightArm,
            },
            -- LeftArm
            ["4637119437"] = {
                tId = AssetTypeEncoder.LeftArm,
            },
            -- LeftLeg
            ["14731377938"] = {
                tId = AssetTypeEncoder.LeftLeg,
            },
            -- RightLeg
            ["14731384498"] = {
                tId = AssetTypeEncoder.RightLeg,
            },
        },
    },
    ["36"] = {
        spawnToTest = true,
        name = "36",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 186563992,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["37"] = {
        spawnToTest = true,
        name = "37",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 113499665,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["38"] = {
        spawnToTest = true,
        name = "38",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 193309568,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },

    ["40"] = {
        spawnToTest = true,
        name = "40",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 6413861640,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["41"] = {
        spawnToTest = true,
        name = "41",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 163429877,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["42"] = {
        spawnToTest = true,
        name = "42",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 2497627172,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["43"] = {
        spawnToTest = true,
        name = "43",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 58482052,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["44"] = {
        spawnToTest = true,
        name = "44",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 293268119,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["45"] = {
        spawnToTest = true,
        name = "45",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 168118521,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["46"] = {
        spawnToTest = true,
        name = "46",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 15791410516,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["47"] = {
        spawnToTest = true,
        name = "47",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 166407042,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["48"] = {
        spawnToTest = true,
        name = "48",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 4535606195,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["49"] = {
        spawnToTest = true,
        name = "49",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 7435836815,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["50"] = {
        spawnToTest = true,
        name = "50",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 165425382,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["52"] = {
        spawnToTest = true,
        name = "52",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 180250327,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["53"] = {
        spawnToTest = true,
        name = "53",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 218357692,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["54"] = {
        spawnToTest = true,
        name = "54",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 7284835510,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["55"] = {
        spawnToTest = true,
        name = "55",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 4261799384,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["56"] = {
        spawnToTest = true,
        name = "56",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 6523339009,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["57"] = {
        spawnToTest = true,
        name = "57",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 5416739451,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["58"] = {
        spawnToTest = true,
        name = "58",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 9656152678,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["59"] = {
        spawnToTest = true,
        name = "59",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 3704440079,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["60"] = {
        spawnToTest = true,
        name = "60",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 9865034674,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["61"] = {
        spawnToTest = true,
        name = "61",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 4776430440,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
    ["62"] = {
        spawnToTest = true,
        name = "62",
        scales = {
            BodyTypeScale = 0.3,
            ProportionScale = 1,
            DepthScale = 1,
            HeadScale = 1,
            HeightScale = 1,
            WidthScale = 1,
        },
        classiClothes = {
            shirt = 6158414691,
            -- pants = 9359707741,
            -- tshirt = 0,
        },
        bodyColors = {
            he = Color3.fromRGB(239, 184, 56),
            lA = Color3.fromRGB(239, 184, 56),
            lL = Color3.fromRGB(239, 184, 56),
            rA = Color3.fromRGB(239, 184, 56),
            rL = Color3.fromRGB(239, 184, 56),
            to = Color3.fromRGB(239, 184, 56),
        },
        -- face = 209994783,
        assets = {
            -- {
            --     id = "15012048860",
            --     AccessoryType = Enum.AccessoryType.Hat,
            --     Order = 1,
            -- },
        },
        bodyParts = {
            -- Torso
            -- ["14498289777"] = {
            --     tId = AssetTypeEncoder.Torso,
            -- },
            -- RightArm
            -- ["4637120775"] = {
            --     tId = AssetTypeEncoder.RightArm,
            -- },
            -- -- LeftArm
            -- ["4637119437"] = {
            --     tId = AssetTypeEncoder.LeftArm,
            -- },
            -- -- LeftLeg
            -- ["14731377938"] = {
            --     tId = AssetTypeEncoder.LeftLeg,
            -- },
            -- -- RightLeg
            -- ["14731384498"] = {
            --     tId = AssetTypeEncoder.RightLeg,
            -- },
        },
    },
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module