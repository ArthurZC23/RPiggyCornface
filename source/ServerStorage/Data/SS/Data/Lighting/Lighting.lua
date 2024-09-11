local module = {}

module.idData = {
    ["0"] = {
        name = "engine",
        props = {
            Blur = {
                Size = 0,
            },
            Bloom = {
                Enabled = false,
                Intensity = 1,
                Size = 46,
                Threshold = 3.213,
            },
            ColorCorrection = {
                Brightness = 0,
                Contrast = 0.1,
                Enabled = false,
                Saturation = 0.11,
                TintColor = Color3.fromRGB(240, 241, 255)
            },
            DepthOfField = {
                Enabled = false,
                FarIntensity = 0.3,
                FocusDistance = 1,
                InFocusRadius = 200,
                NearIntensity = 0,
            },
            Atmosphere = {
                Density = 0,
                Offset = 1,
                Color = Color3.fromRGB(218, 211, 255),
                Decay = Color3.fromRGB(54, 71, 92),
                Glare = 0,
                Haze = 2,
            },
            SunRays = {
                Enabled = false,
                Intensity = 1e-2,
                Spread = 1e-1,
            },
            Sky = {
                CelestialBodiesShown = true,
                MoonAngularSize = 11,
                MoonTextureId = "",
                SkyboxBk = "",
                SkyboxDn = "",
                SkyboxFt = "",
                SkyboxLf = "",
                SkyboxRt = "",
                SkyboxUp = "",
                StarCount = 3000,
                SunAngularSize = 11,
                SunTextureId = "",
            },
            Lighting = {
                Ambient = Color3.fromRGB(141, 141, 141),
                Brightness = 3,
                ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
                ColorShift_Top = Color3.fromRGB(221, 211, 255),
                EnvironmentDiffuseScale = 0,
                EnvironmentSpecularScale = 0,
                GlobalShadows = true,
                OutdoorAmbient = Color3.fromRGB(141, 141, 141),
                ShadowSoftness = 0.17, -- Tecnology: Future
                -- FogColor = Color3.fromRGB(128, 128, 128),
                -- FogEnd = 1e3,
                -- FogStart = 100,
                GeographicLatitude = 0,
                ExposureCompensation = 0,
                TimeOfDay = "14:30:00",
            },
        },
    },
    ["1"] = {
        name = "default",
        props = {
            Blur = {
                Size = 0,
            },
            Bloom = {
                Enabled = true,
                Intensity = 1,
                Size = 46,
                Threshold = 3.213,
            },
            ColorCorrection = {
                Brightness = 0,
                Contrast = 0.1,
                Enabled = true,
                Saturation = 0.11,
                TintColor = Color3.fromRGB(240, 241, 255)
            },
            DepthOfField = {
                Enabled = false,
                FarIntensity = 0.3,
                FocusDistance = 1,
                InFocusRadius = 200,
                NearIntensity = 0,
            },
            Atmosphere = {
                Density = 0.536,
                Offset = 1,
                Color = Color3.fromRGB(218, 211, 255),
                Decay = Color3.fromRGB(54, 71, 92),
                Glare = 0,
                Haze = 2,
            },
            SunRays = {
                Enabled = true,
                Intensity = 1e-2,
                Spread = 1e-1,
            },
            Sky = {
                CelestialBodiesShown = true,
                MoonAngularSize = 11,
                MoonTextureId = "rbxassetid://6444320592",
                SkyboxBk = "rbxassetid://6444884337",
                SkyboxDn = "rbxassetid://6444884785",
                SkyboxFt = "rbxassetid://6444884337",
                SkyboxLf = "rbxassetid://6444884337",
                SkyboxRt = "rbxassetid://6444884337",
                SkyboxUp = "rbxassetid://6412503613",
                StarCount = 3000,
                SunAngularSize = 11,
                SunTextureId = "rbxassetid://6196665106",
            },
            Lighting = {
                Ambient = Color3.fromRGB(30, 26, 24),
                Brightness = 2.5,
                ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
                ColorShift_Top = Color3.fromRGB(221, 211, 255),
                EnvironmentDiffuseScale = 1,
                EnvironmentSpecularScale = 0.29,
                GlobalShadows = true,
                OutdoorAmbient = Color3.fromRGB(44, 45, 63),
                ShadowSoftness = 0.17, -- Tecnology: Future
                -- FogColor = Color3.fromRGB(128, 128, 128),
                -- FogEnd = 1e3,
                -- FogStart = 100,
                GeographicLatitude = 0,
                ExposureCompensation = -1.5,
                TimeOfDay = "09:00:00",
            },
        },
    }
}

module.nameData = {}

for id, data in pairs(module.idData) do
    data.id = id
    module.nameData[data.name] = data
end

return module