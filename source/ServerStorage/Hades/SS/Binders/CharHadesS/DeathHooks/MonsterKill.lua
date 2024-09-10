local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})

--[[
    Kill Anim Human is longer than KillAnimMonster so that the player doesn't get up on core animation before dying.
    If you anchor the monster he will trip when unanchored.
]]--

local Promise = Mod:find({"Promise", "Promise"})

local module = {}

local function killFx(hades, kwargs)
    if kwargs.cmdr then return Promise.resolve() end
    local maid = Maid.new()
    return Promise.try(function()

        local killer = kwargs.killerData.inst
        killer:SetAttribute("canKill", false)
        local animationDuration = 4 -- Depends on game. Also add an +1 second to avoid touching the body
        task.delay(animationDuration, function()
            killer:SetAttribute("canKill", true)
        end)

        local killerData = kwargs.killerData
        local target = hades.char

        local cause = "KillFx"
        do
            local propHumanoid = killerData.binders.charProps.props[killerData.binders.charParts.humanoid]
            maid:Add2(function()
                propHumanoid:removeCause("WalkSpeed", cause)
                propHumanoid:removeCause("JumpPower", cause)
            end)
            propHumanoid:set("WalkSpeed", cause, 0)
            propHumanoid:set("JumpPower", cause, 0)
        end
        do
            local prop = hades.charProps.props[hades.charParts.hrp]
            maid:Add2(function()
                prop:removeCause("Anchored", cause)
            end)
            prop:set("Anchored", cause, true)
        end

        local cf0 = killerData.binders.charParts.KillHumanSRef:GetPivot()
        target:PivotTo(cf0 * CFrame.Angles(0, math.pi, 0) + 6 * cf0.LookVector)

        local killerTrack = killerData.binders.monster.tracks.killAnimation
        local targetTrack = kwargs.targetData.binders.charTeamHuman.tracks.killAnimation

        local ChainsawKillSfx = killerData.binders.charParts.hrp:FindFirstChild("ChainsawKill")
        if ChainsawKillSfx then
            maid:Add2(function()
                ChainsawKillSfx:Stop()
            end)
            ChainsawKillSfx:Play()
        end

        local ScreamSfx = hades.charParts.hrp:FindFirstChild("Scream")
        if ScreamSfx then
            maid:Add2(function()
                ScreamSfx:Stop()
            end)
            ScreamSfx:Play()
        end

        local KillEffect_1 = hades.charParts.hrp:FindFirstChild("KillEffect_1")
        if KillEffect_1 then
            maid:Add2(function()
                KillEffect_1.Enabled = false
            end)
            KillEffect_1.Enabled = true
        end

        killerTrack:Play()
        targetTrack:Play()

        return Promise.all({
            Promise.fromEvent(killerTrack.Stopped),
            Promise.fromEvent(targetTrack.Stopped),
        })
        :timeout(10)
    end)
    :finally(function()
        maid:Destroy()
    end)
end

function module.handler(hades, kwargs)
    local ok, err = killFx(hades, kwargs)
    :finally(function()
        hades.charParts.humanoid.Health = 0
        kwargs.handlerDestroysChar = true
        local char = hades.char
        task.delay(2, function()
            if char.Parent == nil then return end
            char.Parent = nil
            char:Destroy()
        end)
    end)
    :await()
    if not ok then warn(tostring(err)) end
end

return module