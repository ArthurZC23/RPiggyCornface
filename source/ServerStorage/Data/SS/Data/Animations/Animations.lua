local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local TableUtils = Mod:find({"Table", "Utils"})

local Assets = ReplicatedStorage.Assets
local Animations = Assets.Animations

local module = {
    CoreR6 = {
        Default = Animations.CoreR6.Default,
    },
    CoreR15 = {
        Default = Animations.CoreR15.Default,
        Monster = Animations.CoreR15.Monster,
    },
    CoreAnimationsMonster1 = {
        Default = Animations.CoreAnimationsMonster1.Default,
    },
    R15 = {
        Emotes = {

        },
    },
    Monster_R6_1 = {
        Emotes = {

        },
    },
    Kills = {
        OnFloor_1 = {
            Monster = Animations.Kills.OnFloor_1["18442889302"],
            Human = Animations.Kills.OnFloor_1["18442860539"],
        },
    },
}

-- if RunService:IsStudio() then
--     local animSet = {}
--     local anims = TableUtils.getDesc(module)
--     for i, animation in ipairs(anims) do
--         if animSet[animation] then warn(("Animation %s is repeating."):format(animation:GetFullName())) end
--         animSet[animation] = true
--     end
-- end

module.animationsById = {}
for _, desc in ipairs(Animations:GetDescendants()) do
    if not desc:IsA("Animation") then continue end
    module.animationsById[desc.AnimationId] = desc
end

return module