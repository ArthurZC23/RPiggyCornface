local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtils = require(ReplicatedStorage.TableUtils.TableUtils)

local module = {}

module.colorPalette = {
    [1] = Color3.fromRGB(54, 2, 105),
    [2] = Color3.fromRGB(79, 28, 130),
    [3] = Color3.fromRGB(101, 53, 146),
    [4] = Color3.fromRGB(229, 109, 204),
    [5] = Color3.fromRGB(223, 79, 182),
    [6] = Color3.fromRGB(197, 19, 131),
}

module.colorPaletteQty = #module.colorPalette

-- key is the obbyStage id (the id in the obby)
-- val is the stage id (the stage unique id)

module.firstStageId = "1"
module.stages = {
    ["1"] = {
        stage = "1",
        _next = "2",
    },
    ["2"] = {
        stage = "2",
        _next = "3",
    },
    ["3"] = {
        stage = "3",
        _next = "4",
    },
    ["4"] = {
        stage = "4",
        _next = "4_1",
    },
    ["4_1"] = {
        stage = "60",
        _next = "5",
    },
    ["5"] = {
        stage = "5",
        _next = "6",
        start = {
            offset = CFrame.Angles(0, 0.5 * math.pi, 0),
        },
    },
    ["6"] = {
        stage = "6",
        _next = "7",
    },
    ["7"] = {
        stage = "7",
        _next = "8",
        start = {
            offset = CFrame.Angles(0, 0.5 * math.pi, 0),
        },
    },
    ["8"] = {
        stage = "8",
        _next = "9",
    },
    ["9"] = {
        stage = "9",
        _next = "10",
    },
    ["10"] = {
        stage = "10",
        _next = "11",
    },
    ["11"] = {
        stage = "11",
        _next = "12",
    },
    ["12"] = {
        stage = "12",
        _next = "13",
        start = {
            offset = CFrame.Angles(0, 0.5 * math.pi, 0),
        },
    },
    ["13"] = {
        stage = "13",
        _next = "14",
    },
    ["14"] = {
        stage = "14",
        _next = "15",
        start = {
            offset = CFrame.Angles(0, 0.5 * math.pi, 0),
        },
    },
    ["15"] = {
        stage = "15",
        _next = "16",
    },
    ["16"] = {
        stage = "16",
        _next = "17",
    },
    ["17"] = {
        stage = "17",
        _next = "18",
    },
    ["18"] = {
        stage = "18",
        _next = "19",
    },
    ["19"] = {
        stage = "19",
        _next = "20",
        start = {
            offset = CFrame.Angles(0, -0.5 * math.pi, 0),
        },
    },
    ["20"] = {
        stage = "20",
        _next = "21",
    },
    ["21"] = {
        stage = "21",
        _next = "22",
        start = {
            offset = CFrame.Angles(0, -0.5 * math.pi, 0),
        },
    },
    ["22"] = {
        stage = "22",
        _next = "23",
    },
    ["23"] = {
        stage = "23",
        _next = "24",
    },
    ["24"] = {
        stage = "24",
        _next = "25",
    },
    ["25"] = {
        stage = "25",
        _next = "26",
    },
    ["26"] = {
        stage = "26",
        start = {
            offset = CFrame.Angles(0, -0.5 * math.pi, 0),
        },
        _next = "27",
    },
    ["27"] = {
        stage = "27",
        _next = "28",
    },
    ["28"] = {
        stage = "28",
        _next = "29",
    },
    ["29"] = {
        stage = "29",
        _next = "30",
    },
    ["30"] = {
        stage = "30",
        _next = "31",
    },
    ["31"] = {
        stage = "31",
        _next = "31_1",
    },
    ["31_1"] = {
        stage = "59",
        _next = "32",
    },
    ["32"] = {
        stage = "32",
        _next = "33",
    },
    ["33"] = {
        stage = "33",
        _next = "34",
        start = {
            offset = CFrame.Angles(0, -0.5 * math.pi, 0),
        },
    },
    ["34"] = {
        stage = "34",
        _next = "35",
    },
    ["35"] = {
        stage = "35",
        _next = "36",
    },
    ["36"] = {
        stage = "36",
        _next = "37",
    },
    ["37"] = {
        stage = "37",
        _next = "38",
    },
    ["38"] = {
        stage = "38",
        _next = "39",
    },
    ["39"] = {
        stage = "39",
        _next = "40",
    },
    ["40"] = {
        stage = "40",
        _next = "41",
    },
    ["41"] = {
        stage = "41",
        _next = "42",
        start = {
            offset = CFrame.Angles(0, -0.5 * math.pi, 0),
        },
    },
    ["42"] = {
        stage = "42",
        _next = "43",
    },
    ["43"] = {
        stage = "43",
        _next = "44",
    },
    ["44"] = {
        stage = "44",
        _next = "44_1",
    },
    ["44_1"] = {
        stage = "56",
        _next = "45",
    },
    ["45"] = {
        stage = "45",
        _next = "46",
    },
    ["46"] = {
        stage = "58",
        _next = "46_1",
        cf = CFrame.new(47, 180, -245),
    },
    ["46_1"] = {
        stage = "46",
        _next = "47",
    },
    ["47"] = {
        stage = "47",
        _next = "48",
    },
    ["48"] = {
        stage = "48",
        _next = "48_1",
    },
    ["48_1"] = {
        stage = "61",
        _next = "49",
    },
    ["49"] = {
        stage = "49",
        _next = "50",
    },
    ["50"] = {
        stage = "50",
        _next = "50_1",
    },
    ["50_1"] = {
        stage = "57",
        _next = "51",
    },
    ["51"] = {
        stage = "51",
        _next = "52",
    },
    ["52"] = {
        stage = "52",
        _next = "53",
    },
    ["53"] = {
        stage = "53",
        _next = "54",
    },
    ["54"] = {
        stage = "49",
        _next = "55",
    },
    ["55"] = {
        stage = "54",
        _next = "56",
    },
    ["56"] = {
        stage = "55",
        _next = "57",
    },
    ["57"] = {
        stage = "Hangout",
    },
}

module.lastStage = TableUtils.len(module.stages)


return module