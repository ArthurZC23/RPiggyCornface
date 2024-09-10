local RunService = game:GetService("RunService")

local module = {}

local function calculateBrightness(t)
    local T = 48
    local min = 1
    local max = 3
    return min + (max - min) * math.sin(2 * math.pi * t/ T)
end

module.lightConfiguration = {
    ["0"] = {
        Ambient = Color3.fromRGB(255, 255, 255),
        Brightness = calculateBrightness,
        ColorShift_Bottom = Color3.fromRGB(255, 255, 255),
        ColorShift_Top = Color3.fromRGB(255, 255, 255),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.5,
        OutdoorAmbient = Color3.fromRGB(255, 255, 255),
        ColorCorrection = {
            Contrast = 0.2,
            Saturation = 0.1,
            TintColor = Color3.fromRGB(255, 255, 255),
        },
        SunRays = {
            Intensity = 0,
            Spread = 0,
        }
    },
    ["1"] = {

    },
    ["2"] = {

    },
    ["3"] = {

    },
    ["4"] = {

    },
    ["5"] = {

    },
    ["6"] = {
        Ambient = Color3.fromRGB(200, 200, 200),
        Brightness = 2,
        ColorShift_Bottom = Color3.fromRGB(166, 166, 102),
        ColorShift_Top = Color3.fromRGB(221, 190, 65),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.5,
        OutdoorAmbient = Color3.fromRGB(255, 255, 255),
        ColorCorrection = {
            Contrast = 0.2,
            Saturation = 0.1,
        },
        SunRays = {
            Intensity = 0.25,
            Spread = 1,
        }
    },
    ["7"] = {

    },
    ["8"] = {

    },
    ["9"] = {

    },
    ["10"] = {

    },
    ["11"] = {

    },
    ["12"] = {

    },
    ["13"] = {

    },
    ["14"] = {

    },
    ["15"] = {

    },
    ["16"] = {

    },
    ["17"] = {
        Ambient = Color3.fromRGB(200, 147, 134),
        Brightness = 1,
        ColorShift_Bottom = Color3.fromRGB(109, 28, 28),
        ColorShift_Top = Color3.fromRGB(109, 28, 28),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.0,
        OutdoorAmbient = Color3.fromRGB(255, 148, 148),
        ColorCorrection = {
            Contrast = 0.3,
        },
        SunRays = {
            Intensity = 0.5,
        }
    },
    ["18"] = {

    },
    ["19"] = {

    },
    ["20"] = {

    },
    ["21"] = {

    },
    ["22"] = {

    },
    ["23"] = {

    },
}

for time, config in pairs(module.lightConfiguration) do
    local t = tonumber(time)
    config.Brightness = calculateBrightness(t)
end


module.lightFrames = {
    day = {
        Ambient = Color3.fromRGB(200, 200, 200),
        Brightness = 2,
        ColorShift_Bottom = Color3.fromRGB(166, 166, 102),
        ColorShift_Top = Color3.fromRGB(221, 190, 65),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.5,
        OutdoorAmbient = Color3.fromRGB(255, 255, 255),
        ColorCorrection = {
            Contrast = 0.2,
            Saturation = 0.1,
        },
        SunRays = {
            Intensity = 0.25,
            Spread = 1,
        }
    },
    afternoon = {
        Ambient = Color3.fromRGB(200, 147, 134),
        Brightness = 1,
        ColorShift_Bottom = Color3.fromRGB(109, 28, 28),
        ColorShift_Top = Color3.fromRGB(109, 28, 28),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.0,
        OutdoorAmbient = Color3.fromRGB(255, 148, 148),
        ColorCorrection = {
            Contrast = 0.3,
            Saturation = 0.1,
        },
        SunRays = {
            Intensity = 0.5,
            Spread = 1,
        }
    },
    night = {
        Ambient = Color3.fromRGB(173, 200, 197),
        Brightness = 3,
        ColorShift_Bottom = Color3.fromRGB(159, 200, 198),
        ColorShift_Top = Color3.fromRGB(159, 200, 198),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.5,
        OutdoorAmbient = Color3.fromRGB(173, 200, 197),
        ColorCorrection = {
            Contrast = 0.1,
            Saturation = -0.1,
        },
        SunRays = {
            Intensity = 0,
            Spread = 0,
        }
    },
}

module.clockTimeToTimeRange = {
    ["6"] = "day",
    ["16"] = "afternoon",
    ["21"] = "night"
}

return module