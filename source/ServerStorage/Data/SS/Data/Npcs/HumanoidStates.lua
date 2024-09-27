local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local prototype = {
    [Enum.HumanoidStateType.FallingDown] = false,
    [Enum.HumanoidStateType.Running] = true,
    [Enum.HumanoidStateType.RunningNoPhysics] = true,
    [Enum.HumanoidStateType.Climbing] = false,
    [Enum.HumanoidStateType.StrafingNoPhysics] = false,
    [Enum.HumanoidStateType.Ragdoll] = false,
    [Enum.HumanoidStateType.GettingUp] = false,
    [Enum.HumanoidStateType.Jumping] = false,
    [Enum.HumanoidStateType.Landed] = false,
    [Enum.HumanoidStateType.Flying] = false,
    [Enum.HumanoidStateType.Freefall] = false,
    [Enum.HumanoidStateType.Seated] = false,
    [Enum.HumanoidStateType.PlatformStanding] = false,
    [Enum.HumanoidStateType.Dead] = false,
    [Enum.HumanoidStateType.Swimming] = false,
    [Enum.HumanoidStateType.Physics] = false,
}

local module = {}

module = {
    ["Monster"] = {},
    ["charPhyDummy"] = {
        [Enum.HumanoidStateType.FallingDown] = true,
        [Enum.HumanoidStateType.Running] = true,
        [Enum.HumanoidStateType.RunningNoPhysics] = true,
        [Enum.HumanoidStateType.Climbing] = true,
        [Enum.HumanoidStateType.StrafingNoPhysics] = true,
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.GettingUp] = true,
        [Enum.HumanoidStateType.Jumping] = true,
        [Enum.HumanoidStateType.Landed] = true,
        [Enum.HumanoidStateType.Flying] = true,
        [Enum.HumanoidStateType.Freefall] = true,
        [Enum.HumanoidStateType.Seated] = true,
        [Enum.HumanoidStateType.PlatformStanding] = true,
        [Enum.HumanoidStateType.Dead] = true,
        [Enum.HumanoidStateType.Swimming] = true,
        [Enum.HumanoidStateType.Physics] = true,
    },
    ["idle"] = {},
    ["ugcDummy"] = {},
    ["dummy"] = {
        [Enum.HumanoidStateType.FallingDown] = true,
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.GettingUp] = true,
        [Enum.HumanoidStateType.Dead] = true,
        [Enum.HumanoidStateType.Physics] = true,
    },

}

for id in pairs(module) do
    TableUtils.setProto(module[id], prototype)
end

return module