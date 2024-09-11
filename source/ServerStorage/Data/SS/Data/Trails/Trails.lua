local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local Data = script:FindFirstAncestor("Data")
local GpData = require(Data.GamePasses.GamePasses)
local S = require(Data.Strings.Strings)

local module = {}

local protoProps = {
    LightEmission = 1,
    LightInfluence = 0,
    FaceCamera = true,
    Lifetime = 0.5,
    WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0),
    }),
}

module.idData = {
    -- ["0"] = {
    --     name = "Vip",
    --     prettyName = "VIP",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(248,242,191)),
    --             ColorSequenceKeypoint.new(0.29, Color3.fromRGB(248,242,191)),
    --             ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0,34,99)),
    --             ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,34,99)),
    --             ColorSequenceKeypoint.new(0.61, Color3.fromRGB(137,3,4)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(137,3,4)),
    --         }),
    --         Transparency = NumberSequence.new({
    --             NumberSequenceKeypoint.new(0, 0),
    --             NumberSequenceKeypoint.new(1, 0),
    --         }),
    --     },
    --     rewards = {
    --         shop = {
    --             _type = "Gamepass",
    --             gpId = GpData.nameToData[S.VipGp].id,
    --         },
    --     },
    --     ui = {},
    -- },
    -- ["1"] = {
    --     name = "White",
    --     prettyName = "White",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = "free",
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(255, 255, 255),
    --     },
    -- },
    -- ["2"] = {
    --     name = "BrightGreen",
    --     prettyName = "Bright Green",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 151, 75)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 151, 75)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 1,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(75, 151, 75),
    --     },
    -- },
    -- ["3"] = {
    --     name = "Black",
    --     prettyName = "Black",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 42, 53)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(27, 42, 53)),
    --         }),
    --         Transparency = NumberSequence.new({
    --             NumberSequenceKeypoint.new(0, 0),
    --             NumberSequenceKeypoint.new(1, 0),
    --         }),
    --         LightEmission = 0,
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 2,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(27, 42, 53),
    --     },
    -- },

    -- ["4"] = {
    --     name = "BrightRed",
    --     prettyName = "Bright Red",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(196, 40, 28)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(196, 40, 28)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 3,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(196, 40, 28),
    --     },
    -- },
    -- ["5"] = {
    --     name = "RoyalPurple",
    --     prettyName = "Royal Purple",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 37, 209)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(98, 37, 209)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 4,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(98, 37, 209),
    --     },
    -- },
    -- ["6"] = {
    --     name = "Cyan",
    --     prettyName = "Cyan",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 175, 236)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 175, 236)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 5,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(4, 175, 236),
    --     },
    -- },
    -- ["7"] = {
    --     name = "Brown",
    --     prettyName = "Brown",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 64, 40)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 64, 40)),
    --         }),
    --         LightEmission = 0,
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 6,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(105, 64, 40),
    --     },
    -- },
    -- ["8"] = {
    --     name = "DarkBlue",
    --     prettyName = "Dark Blue",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 16, 176)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 16, 176)),
    --         }),
    --         LightEmission = 0,
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 7,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(0, 16, 176),
    --     },
    -- },
    -- ["9"] = {
    --     name = "Orange",
    --     prettyName = "Orange",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 145, 97)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 145, 97)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 8,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(235, 145, 97),
    --     },
    -- },
    -- ["10"] = {
    --     name = "Gold",
    --     prettyName = "Gold",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(239, 184, 56)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(239, 184, 56)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 9,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(239, 184, 56),
    --     },
    -- },
    -- ["11"] = {
    --     name = "Pink",
    --     prettyName = "Pink",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 191)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 191)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 10,
    --         },
    --     },
    --     ui = {
    --         color = Color3.fromRGB(255, 0, 191),
    --     },
    -- },
    -- ["12"] = {
    --     name = "RedGreen",
    --     prettyName = "Red Green",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 15,
    --         },
    --     },
    --     ui = {},
    -- },
    -- ["13"] = {
    --     name = "BlueYellow",
    --     prettyName = "Blue Yellow",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 255)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 20,
    --         },
    --     },
    --     ui = {},
    -- },
    -- ["14"] = {
    --     name = "BlackYellow",
    --     prettyName = "Black Yellow",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromHex("101820")),
    --             ColorSequenceKeypoint.new(1, Color3.fromHex("FEE715")),
    --         }),
    --         LightEmission = 0,
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 25,
    --         },
    --     },
    --     ui = {},
    -- },
    -- ["15"] = {
    --     name = "PinkCyan",
    --     prettyName = "Pink Cyan",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromHex("FF69B4")),
    --             ColorSequenceKeypoint.new(1, Color3.fromHex("00FFFF")),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 30,
    --         },
    --     },
    --     ui = {},
    -- },
    -- ["16"] = {
    --     name = "PeachOrange",
    --     prettyName = "Peach Orange",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromHex("FCEDDA")),
    --             ColorSequenceKeypoint.new(1, Color3.fromHex("EE4E34")),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = S.FinishChapter,
    --             price = 35,
    --         },
    --     },
    --     ui = {},
    -- },
    -- ["100"] = {
    --     name = "Rainbow",
    --     prettyName = "Rainbow",
    --     trailProps = {
    --         Color = ColorSequence.new({
    --             ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    --             ColorSequenceKeypoint.new(1/5, Color3.fromRGB(255, 255, 0)),
    --             ColorSequenceKeypoint.new(2/5, Color3.fromRGB(0, 255, 0)),
    --             ColorSequenceKeypoint.new(3/5, Color3.fromRGB(0, 255, 255)),
    --             ColorSequenceKeypoint.new(4/5, Color3.fromRGB(0, 0, 255)),
    --             ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
    --         })
    --     },
    --     rewards = {
    --         shop = {
    --             _type = "Gamepass",
    --             gpId = GpData.nameToData[S.VipGp].id,
    --         },
    --     },
    --     ui = {},
    -- },
}

for id, data in pairs(module.idData) do
    TableUtils.setProto(data.trailProps, protoProps)
    if not data.ui.LayoutOrder then
        data.ui.LayoutOrder = tonumber(id)
    end
end

return module