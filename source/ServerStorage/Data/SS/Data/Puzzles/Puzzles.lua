local Data = script:FindFirstAncestor("Data")
local Keys = require(Data.Puzzles.Keys)

local module = {}

module.idData = {
    ["1"] = {
        name = "AxePuzzle",
        keys = {
            [Keys.nameData.Axe.id] = true,
        },
    },
    ["2"] = {
        name = "HammerPuzzle",
        keys = {
            [Keys.nameData.Hammer.id] = true,
        },
    },
    ["3"] = {
        name = "KeyYellowPuzzle",
        keys = {
            [Keys.nameData.KeyYellow.id] = true,
        },
    },
    -- ["4"] = {
    --     name = "SawPuzzle",
    --     keys = {
    --         [Keys.nameData.Saw.id] = true,
    --     },
    -- },
    ["5"] = {
        name = "ScrewdriverPuzzle",
        keys = {
            [Keys.nameData.Screwdriver.id] = true,
        },
    },
    ["6"] = {
        name = "ShapeBallBluePuzzle",
        keys = {
            [Keys.nameData.ShapeBallBlue.id] = true,
        },
    },
    ["7"] = {
        name = "ShapeCubeRedPuzzle",
        keys = {
            [Keys.nameData.ShapeCubeRed.id] = true,
        },
    },
    ["8"] = {
        name = "ShapeTrianglePinkPuzzle",
        keys = {
            [Keys.nameData.ShapeTrianglePink.id] = true,
        },
    },
    ["9"] = {
        name = "ShovelPuzzle",
        keys = {
            [Keys.nameData.Shovel.id] = true,
        },
    },
    ["10"] = {
        name = "WoodPlankPuzzle",
        keys = {
            [Keys.nameData.WoodPlank.id] = true,
        },
    },
    ["11"] = {
        name = "ScythePuzzle",
        keys = {
            [Keys.nameData.Scythe.id] = true,
        },
    },
    ["12"] = {
        name = "KeyRedPuzzle",
        keys = {
            [Keys.nameData.KeyRed.id] = true,
        },
    },
}

return module