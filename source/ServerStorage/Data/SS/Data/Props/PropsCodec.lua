local module = {}

module.encoder = {}
module.decoder = {}

module.encoder = {
    -- Add new key name to props to separate size form blur size
    Size = {
        Default = "-100",
        Skill = "10",
        LoadingScreen = "1000",
    },
    Brightness = {
        Default = "-100",
        Skill = "10",
    },
    Material = {
        Default = "-100",
        Emote = "1",
    },
    Color = {
        Default = "-100",
        Emote = "1",
    },
    TextureID = {
        Default = "-100",
        Emote = "1",
    },
    Contrast = {
        Default = "-100",
        Skill = "10",
    },
    Saturation = {
        Default = "-100",
        Skill = "10",
    },
    TintColor = {
        Default = "-100",
        Skill = "10",
    },
    Enabled = {
        Default = "-100",
        Skill = "10",
        CharPhysicsDummy = "1000",
    },
    FarIntensity = {
        Default = "-100",
        Skill = "10",
    },
    FocusDistance = {
        Default = "-100",
        Skill = "10",
    },
    InFocusRadius = {
        Default = "-100",
        Skill = "10",
    },
    NearIntensity = {
        Default = "-100",
        Skill = "10",
    },
    TimeOfDay = {
        Default = "-100",
    },
    Ambient = {
        Default = "-100",
        Skill = "10",
    },
    OutdoorAmbient = {
        Default = "-100",
        Skill = "10",
    },
    FogColor = {
        Default = "-100",
        Skill = "10",
    },
    FogEnd = {
        Default = "-100",
        Skill = "10",
    },
    FogStart = {
        Default = "-100",
        Skill = "10",
    },
    Transparency = {
        Default = "-100",
        NotMorph = "-96",
        Morph = "-95",
        ShowTool = "-90",
        Skill = "10",
        Boost = "21",
        Invisible = "100",
        Hide = "200",
        CharPhysicsDummy = "1000",
    },
    Anchored = {
        Default = "-100",
        Interaction = "5",
        Movement = "10",
        KillFx = "800",
        CharPhysicsDummy = "1000",
        Flinge = tostring(1e4),
    },
    WalkSpeed = {
        Default = "-100",
        Points = "1",
        PlayerSet = "10",
        GpBoost = "20",
        Boost = "21",
        LockMovementKeepDirectionInput = "30",
        LockMovementInput = "40",
        Tool = "100",
        Hide = "200",
        Mg = "400",
        Stun = "500",
        KillFx = "800",
        StartScreen = "1000",
    },
    JumpPower = {
        Default = "-100",
        PlayerSet = "10",
        GpBoost = "20",
        Boost = "21",
        LockMovementKeepDirectionInput = "30",
        LockMovementInput = "40",
        Tool = "100",
        Hide = "200",
        Stun = "500",
        KillFx = "800",
        StartScreen = "1000",
    },
    Text = {
        Default = "-100",
        Obstacle = "200",
    },
    CameraSubject = {
        Default = "-100",
        Skill = "7",
    },
    CameraType = {
        Default = "-100",
        Skill = "7",
    },
    CameraLock = {
        Default = "-100",
        UserChoice = "0",
        Skill = "10",
    },
    FieldOfView = {
        Default = "-100",
        Skill = "7",
    },
    CameraMinZoomDistance = {
        Default = "-100",
        Skill = "7",
    },
    CameraMaxZoomDistance = {
        Default = "-100",
        Skill = "7",
    },
    FillColor = {
        Default = "-100",
        TakeDamage = "0",
        Skill = "10",
        SkillAim = "30",
        Invisible = "100",
    },
    FillTransparency = {
        Default = "-100",
        TakeDamage = "0",
        Skill = "10",
        SkillAim = "30",
        Invisible = "100",
    },
    OutlineColor = {
        Default = "-100",
        TakeDamage = "0",
        Skill = "10",
        SkillAim = "30",
        Invisible = "100",
    },
    OutlineTransparency = {
        Default = "-100",
        TakeDamage = "0",
        Skill = "10",
        SkillAim = "30",
        Invisible = "100",
    },
}

for prop, codes in pairs(module.encoder) do
    for cause, priority in pairs(codes) do
        module.decoder[priority] = {prop, cause}
    end
end

module.NIL_CAUSE = "No Cause"
module.NIL_CAUSE_PRIORITY = -math.huge

return module