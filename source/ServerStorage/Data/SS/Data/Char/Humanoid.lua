local module = {}

module.WalkSpeed = {
    Default = 16,
}

module.States = {
    [Enum.HumanoidStateType.FallingDown] = "FallingDown",
    [Enum.HumanoidStateType.Running] = "Running",
    [Enum.HumanoidStateType.RunningNoPhysics] = "RunningNoPhysics",
    [Enum.HumanoidStateType.StrafingNoPhysics] = "StrafingNoPhysics",
    [Enum.HumanoidStateType.Ragdoll] = "Ragdoll",
    [Enum.HumanoidStateType.GettingUp] = "GettingUp",
    [Enum.HumanoidStateType.Jumping] = "Jumping",
    [Enum.HumanoidStateType.Landed] = "Landed",
    [Enum.HumanoidStateType.Flying] = "Flying",
    [Enum.HumanoidStateType.Freefall] = "Freefall",
    [Enum.HumanoidStateType.Seated] = "Seated",
    [Enum.HumanoidStateType.PlatformStanding] = "PlatformStanding",
    [Enum.HumanoidStateType.Dead] = "Dead",
    [Enum.HumanoidStateType.Swimming] = "Swimming",
    [Enum.HumanoidStateType.Physics] = "Physics",
    [Enum.HumanoidStateType.None] = "None",
}

module.DescriptionProperties = {
    ["BackAccessory"] = "BackAccessory",
    ["BodyTypeScale"] = "BodyTypeScale",
    ["ClimbAnimation"] = "ClimbAnimation",
    ["DepthScale"] = "DepthScale",
    ["Face"] = "Face",
    ["FaceAccessory"] = "FaceAccessory",
    ["FallAnimation"] = "FallAnimation",
    ["FrontAccessory"] = "FrontAccessory",
    ["GraphicTShirt"] = "GraphicTShirt",
    ["HairAccessory"] = "HairAccessory",
    ["HatAccessory"] = "HatAccessory",
    ["Head"] = "Head",
    ["HeadColor"] = "HeadColor",
    ["HeadScale"] = "HeadScale",
    ["HeightScale"] = "HeightScale",
    ["IdleAnimation"] = "IdleAnimation",
    ["JumpAnimation"] = "JumpAnimation",
    ["LeftArm"] = "LeftArm",
    ["LeftArmColor"] = "LeftArmColor",
    ["LeftLeg"] = "LeftLeg",
    ["LeftLegColor"] = "LeftLegColor",
    ["NeckAccessory"] = "NeckAccessory",
    ["Pants"] = "Pants",
    ["ProportionScale"] = "ProportionScale",
    ["RightArm"] = "RightArm",
    ["RightArmColor"] = "RightArmColor",
    ["RightLeg"] = "RightLeg",
    ["RightLegColor"] = "RightLegColor",
    ["RunAnimation"] = "RunAnimation",
    ["Shirt"] = "Shirt",
    ["ShouldersAccessory"] = "ShouldersAccessory",
    ["SwimAnimation"] = "SwimAnimation",
    ["Torso"] = "Torso",
    ["TorsoColor"] = "TorsoColor",
    ["WaistAccessory"] = "WaistAccessory",
    ["WalkAnimation"] = "WalkAnimation",
    ["WidthScale"] = "WidthScale",
}

return module

