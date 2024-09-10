local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})
local Data = script:FindFirstAncestor("Data")
local GameData = require(Data.Game.Game)

local module = {}

module.speed = {
    default = 16,
    running = 26,
}

-- if RunService:IsStudio() then
--     module.speed.default = 32
-- end

module.jumpPower = {
    default = 50,
}

module.jointsR6 = {
    rootJoint = {
        instName = "RootJoint",
        ParentName = "hrp",
    },
    leftHip = {
        instName = "Left Hip",
        ParentName = "torso",
    },
    rightHip = {
        instName = "Right Hip",
        ParentName = "torso",
    },
    leftShoulder = {
        instName = "Left Shoulder",
        ParentName = "torso",
    },
    rightShoulder = {
        instName = "Right Shoulder",
        ParentName = "torso",
    },
    neck = {
        instName = "Neck",
        ParentName = "torso",
    },
}
module.jointsR15 = {
    neck = {
        instName = "Neck",
        ParentName = "head",
    },

    leftAnkle = {
        instName = "LeftAnkle",
        ParentName = "leftFoot",
    },
    leftWrist = {
        instName = "LeftWrist",
        ParentName = "leftHand",
    },
    leftElbow = {
        instName = "LeftElbow",
        ParentName = "leftLowerArm",
    },
    leftKnee = {
        instName = "LeftKnee",
        ParentName = "leftLowerLeg",
    },
    leftShoulder = {
        instName = "LeftShoulder",
        ParentName = "leftUpperArm",
    },
    leftHip = {
        instName = "LeftHip",
        ParentName = "leftUpperLeg",
    },

    root = {
        instName = "Root",
        ParentName = "lowerTorso",
    },

    rightAnkle = {
        instName = "RightAnkle",
        ParentName = "rightFoot",
    },
    rightWrist = {
        instName = "RightWrist",
        ParentName = "rightHand",
    },
    rightElbow = {
        instName = "RightElbow",
        ParentName = "rightLowerArm",
    },
    rightKnee = {
        instName = "RightKnee",
        ParentName = "rightLowerLeg",
    },
    rightShoulder = {
        instName = "RightShoulder",
        ParentName = "rightUpperArm",
    },
    rightHip = {
        instName = "RightHip",
        ParentName = "rightUpperLeg",
    },
    waist = {
        instName = "Waist",
        ParentName = "upperTorso",
    },
}

module.jointsDog1 = {

}
module.jointsDog2 = {

}
module.jointsDog3 = {

}
module.jointsDog4 = {

}
module.jointsDog5 = {

}
module.jointsDog6 = {

}
module.jointsDog7 = {

}
module.jointsDog8 = {

}
module.jointsDog9 = {

}
module.jointsDog10 = {

}
module.jointsDog11 = {

}
module.jointsDog12 = {

}

module.jointsDog13 = {

}

module.attachmentsR6 = {
    BbBottomBackAttachment = {
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(0, -0.5 * 5, 0.5 * 1),
        extra = true,
        ParentName = "boundingBox",
    },
    BbTopBackAttachment = {
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(0, 0.5 * 5, 0.5 * 1),
        extra = true,
        ParentName = "boundingBox",
    },
    BbBottomFrontAttachment = {
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(0, -0.5 * 5, -0.5 * 1),
        extra = true,
        ParentName = "boundingBox",
    },
    HrpGroundFrontArrowAttachment = {
        Orientation = Vector3.new(0, 0, 90),
        Position = Vector3.new(0, -0.45 * 5, -0.5 * 1),
        extra = true,
        ParentName = "hrp",
    },
    WaistCenterLeftAttachment = {
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(-1, -1, 0),
        extra = true,
        ParentName = "torso",
    },
    WaistCenterRightAttachment = {
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(1, -1, 0),
        extra = true,
        ParentName = "torso",
    },
    MouthAttachment = {
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(0, -0.25, -0.6),
        extra = true,
        ParentName = "head",
    },
    FaceCenterAttachment = {
        ParentName = "head",
    },
    FaceFrontAttachment = {
        ParentName = "head",
    },
    HairAttachment = {
        ParentName = "head",
    },
    HatAttachment = {
        ParentName = "head",
    },
    RootAttachment = {
        ParentName = "hrp",
    },
    LeftGripAttachment = {
        ParentName = "leftArm",
    },
    LeftShoulderAttachment = {
        ParentName = "leftArm",
    },
    LeftFootAttachment = {
        ParentName = "leftLeg",
    },
    RightGripAttachment = {
        ParentName = "rightArm",
    },
    RightShoulderAttachment = {
        ParentName = "rightArm",
    },
    RightFootAttachment = {
        ParentName = "rightLeg",
    },
    BodyBackAttachment = {
        ParentName = "torso",
    },
    BodyFrontAttachment = {
        ParentName = "torso",
    },
    LeftCollarAttachment = {
        ParentName = "torso",
    },
    NeckAttachment = {
        ParentName = "torso",
    },
    RightCollarAttachment = {
        ParentName = "torso",
    },
    WaistBackAttachment = {
        ParentName = "torso",
    },
    WaistCenterAttachment = {
        ParentName = "torso",
    },
    WaistFrontAttachment = {
        ParentName = "torso",
    },
}

-- Not all attachs load in all R15 rigs. This breaks my framework. So only use attachments that
-- I create myself.
module.attachmentsR15 = {
    -- FaceCenterAttachment = {
    --     ParentName = "head",
    -- },
    -- FaceFrontAttachment = {
    --     ParentName = "head",
    -- },
    -- HairAttachment = {
    --     ParentName = "head",
    -- },
    -- HatAttachment = {
    --     ParentName = "head",
    -- },
    -- NeckRigAttachment_Head = {
    --     attachName = "NeckRigAttachment",
    --     ParentName = "head",
    -- },
    -- LeftAnkleRigAttachment_Foot = {
    --     attachName = "LeftAnkleRigAttachment",
    --     ParentName = "leftFoot",
    -- },
    -- LeftFootAttachment = {
    --     ParentName = "leftFoot",
    -- },
    -- LeftGripAttachment = {
    --     ParentName = "leftHand",
    -- },
    -- LeftWristRigAttachment_Hand = {
    --     attachName = "LeftWristRigAttachment",
    --     ParentName = "leftHand",
    -- },
    -- LeftElbowRigAttachment = {
    --     ParentName = "leftLowerArm",
    -- },
    -- LeftWristRigAttachment_LowerArm = {
    --     attachName = "LeftWristRigAttachment",
    --     ParentName = "leftLowerArm",
    -- },
    -- LeftAnkleRigAttachment = {
    --     ParentName = "leftLowerLeg",
    -- },
    -- LeftKneeRigAttachment_LowerLeg = {
    --     attachName = "LeftKneeRigAttachment",
    --     ParentName = "leftLowerLeg",
    -- },
    -- LeftElbowRigAttachment_UpperArm = {
    --     attachName = "LeftElbowRigAttachment",
    --     ParentName = "leftUpperArm",
    -- },
    -- LeftShoulderAttachment = {
    --     ParentName = "leftUpperArm",
    -- },
    -- LeftShoulderRigAttachment_UpperArm = {
    --     attachName = "LeftShoulderRigAttachment",
    --     ParentName = "leftUpperArm",
    -- },
    -- LeftHipRigAttachment_UpperLeg = {
    --     attachName = "LeftHipRigAttachment",
    --     ParentName = "leftUpperLeg",
    -- },
    -- LeftKneeRigAttachment = {
    --     ParentName = "leftUpperLeg",
    -- },
    -- LeftHipRigAttachment_LowerTorso = {
    --     attachName = "LeftHipRigAttachment",
    --     ParentName = "lowerTorso",
    -- },
    -- RightHipRigAttachment_LowerTorso = {
    --     attachName = "RightHipRigAttachment",
    --     ParentName = "lowerTorso",
    -- },
    -- RootRigAttachment_LowerTorso = {
    --     attachName = "RootRigAttachment",
    --     ParentName = "lowerTorso",
    -- },
    -- WaistBackAttachment = {
    --     ParentName = "lowerTorso",
    -- },
    -- WaistCenterAttachment = {
    --     ParentName = "lowerTorso",
    -- },
    -- WaistFrontAttachment = {
    --     ParentName = "lowerTorso",
    -- },
    WaistRigAttachment_LowerTorso = {
        attachName = "WaistRigAttachment",
        ParentName = "lowerTorso",
    },
    -- RightAnkleRigAttachment = {
    --     ParentName = "rightFoot",
    -- },
    -- RightFootAttachment = {
    --     ParentName = "rightFoot",
    -- },
    -- -- RightGripAttachment = {
    -- --     ParentName = "rightHand",
    -- -- },
    -- RightWristRigAttachment_Hand = {
    --     attachName = "RightWristRigAttachment",
    --     ParentName = "rightHand",
    -- },
    -- RightElbowRigAttachment = {
    --     ParentName = "rightLowerArm",
    -- },
    -- RightWristRigAttachment_LowerArm = {
    --     attachName = "RightWristRigAttachment",
    --     ParentName = "rightLowerArm",
    -- },
    -- RightAnkleRigAttachment_LowerLeg = {
    --     attachName = "RightAnkleRigAttachment",
    --     ParentName = "rightLowerLeg",
    -- },
    -- RightKneeRigAttachment_LowerLeg = {
    --     attachName = "RightKneeRigAttachment",
    --     ParentName = "rightLowerLeg",
    -- },
    -- RightElbowRigAttachment_UpperArm = {
    --     attachName = "RightElbowRigAttachment",
    --     ParentName = "rightUpperArm",
    -- },
    -- RightShoulderAttachment = {
    --     ParentName = "rightUpperArm",
    -- },
    -- RightShoulderRigAttachment_UpperArm = {
    --     attachName = "RightShoulderRigAttachment",
    --     ParentName = "rightUpperArm",
    -- },
    -- RightHipRigAttachment_UpperLeg = {
    --     attachName = "RightHipRigAttachment",
    --     ParentName = "rightUpperLeg",
    -- },
    -- RightKneeRigAttachment_UpperLeg = {
    --     attachName = "RightKneeRigAttachment",
    --     ParentName = "rightUpperLeg",
    -- },
    -- BodyBackAttachment = {
    --     ParentName = "upperTorso",
    -- },
    -- BodyFrontAttachment = {
    --     ParentName = "upperTorso",
    -- },
    -- LeftCollarAttachment = {
    --     ParentName = "upperTorso",
    -- },
    -- LeftShoulderRigAttachment_UpperTorso = {
    --     attachName = "LeftShoulderRigAttachment",
    --     ParentName = "upperTorso",
    -- },
    NeckRigAttachment_UpperTorso = {
        attachName = "NeckRigAttachment",
        ParentName = "upperTorso",
    },
    -- RightCollarAttachment = {
    --     ParentName = "upperTorso",
    -- },
    -- RightShoulderRigAttachment_UpperTorso = {
    --     attachName = "RightShoulderRigAttachment",
    --     ParentName = "upperTorso",
    -- },
    -- WaistRigAttachment_UpperTorso = {
    --     attachName = "WaistRigAttachment",
    --     ParentName = "upperTorso",
    -- },
    -- RootAttachment = {
    --     ParentName = "hrp",
    -- },
    -- RootRigAttachment_Hrp = {
    --     attachName = "RootRigAttachment",
    --     ParentName = "hrp",
    -- },
    RootRigAttachment = {
        extra = true,
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(0, -1, 0),
        ParentName = "hrp",
    },
    RightGripAttachment = {
        extra = true,
        Orientation = Vector3.new(-90, 0, 0),
        Position = Vector3.new(0, -0.158, -0),
        ParentName = "rightHand",
    },
    MouthAttachment = {
        extra = true,
        Orientation = Vector3.new(0, 0, 0),
        Position = Vector3.new(0, -0.2, -0.58),
        ParentName = "head",
    },
}

module.attachmentsMonster_R6_1 = {}

-- print("Attach R15: ", TableUtils.len(module.attachmentsR15))

return module