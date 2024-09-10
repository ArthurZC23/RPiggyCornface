local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Data = Mod:find({"Data", "Data"})
local SuperUsers = Data.Players.Roles.HiddenRoles.HiddenRoles.SuperUsers
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local S = Data.Strings.Strings
local Policies = Data.Players.Policies.Policies
local GroupRoles = Data.Players.Roles.GroupRoles.GroupRoles

local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})

local function hasPolicyPermission(group, playerRolePolicies)
    if group == "DefaultAdmin" and playerRolePolicies[Policies.policies.owner.name] then
        return true
    end
    if group == "tester" and playerRolePolicies[Policies.policies.tester.name] then
        return true
    end
    if group == "tester" and playerRolePolicies[Policies.policies.tester.name] then
        return true
    end

    if
        group == "moderatorTrainee" and (playerRolePolicies[Policies.policies.moderatorTrainee.name])
    then
        return true
    end

    if group == "moderator" and playerRolePolicies[Policies.policies.moderator.name] then
        return true
    end
end

return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
        local shouldStopCmd = nil -- needs to be nil to run

        if RunService:IsStudio() then return shouldStopCmd end
        -- if SuperUsers[tostring(context.Executor.UserId)] then
        --     return shouldStopCmd
        -- end

        if context.Group["any"] then return shouldStopCmd end

        local player = context.Executor
        local role = player:GetAttribute("groupRole")
        if not role then return false end

        -- print("Role: ", role)
        local playerRolePolicies = GroupRoles.roles[role].policies
        local _hasPolicyPermission = hasPolicyPermission(context.Group, playerRolePolicies)
        if _hasPolicyPermission then return shouldStopCmd end

        -- All commands run on init...why?
        -- print("You don't have permission to run this command!")
        shouldStopCmd = true
        return shouldStopCmd
	end)
end