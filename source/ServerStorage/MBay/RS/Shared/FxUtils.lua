local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local GaiaShared = Mod:find({"Gaia", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local Maid = Mod:find({"Maid"})
local Promise = Mod:find({"Promise", "Promise"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local FastMode = Mod:find({"FastMode", "Shared", "FastMode"})
local Platforms = Mod:find({"Platforms", "Platforms"})
local TableUtils = Mod:find({"Table", "Utils"})

local module = {}

function module.loadSounds(tbl, soundsData)
    local maid = Maid.new()
    for soundName, sData in pairs(soundsData) do
        local sound = sData.proto:Clone()
        local props = sData.props or {}
        TableUtils.setInstance(sound, props)
        sound.Parent = sData.parent
        tbl[soundName] = sound
    end
    maid:Add(function()
        for sName, sound in pairs(tbl) do
            sound:Destroy()
        end
    end)
    return maid
end

function module.setFxsCfsWithAttach(inst, charAttach, kwargs)
    kwargs = kwargs or {}
    local part
    if inst:IsA("BasePart") then
        part = inst
    elseif inst:IsA("Model") then
        part = inst.PrimaryPart
    end
    local cf0 = inst:GetAttribute("cf0")
    assert(cf0)
    local attach = charAttach.attachs[cf0]

    local offset = kwargs.offset or Vector3.new(0, 0, 0)
    local cfOffset = kwargs.cfOffset or CFrame.identity
    local refCf = attach.WorldCFrame
    inst:PivotTo(refCf * cfOffset + refCf:vectorToWorldSpace(offset))
    local attachParent = attach.Parent

    local weld = inst:GetAttribute("weld")
    local anchored = inst:GetAttribute("anchored")
    local motor6D = inst:GetAttribute("motor6D")
    if weld then
        assert(anchored == nil and motor6D == nil)
        part.Anchored = false
        local name = kwargs.weldName or "WeldConstraint"
        GaiaShared.create("WeldConstraint", {
            Parent = part,
            Part0 = part,
            Part1 = attachParent,
            Name = name,
        })
    end
    if anchored then
        assert(weld == nil and motor6D == nil)
        part.Anchored = true
    end
end

function module.setFxsCfs(inst, charParts, kwargs)
    kwargs = kwargs or {}
    local part
    if inst:IsA("BasePart") then
        part = inst
    elseif inst:IsA("Model") then
        part = inst.PrimaryPart
    end
    local cf0 = inst:GetAttribute("cf0")
    assert(cf0)
    local ref
    if cf0 == "bb" then
        ref = charParts.boundingBox
    elseif charParts[cf0] then
        ref = charParts[cf0]
    end
    local offset = kwargs.offset or Vector3.new(0, 0, 0)
    local cfOffset = kwargs.cfOffset or CFrame.identity
    inst:PivotTo(ref.CFrame * cfOffset + ref.CFrame:vectorToWorldSpace(offset))

    local s0 = inst:GetAttribute("s0")
    if s0 then
        if s0 == "bb" then
            part.Size = charParts.boundingBox.Size
        elseif s0 == "hrp" then
            part.Size = charParts.hrp.Size
        elseif s0 == "head" then
            part.Size = charParts.head.Size
        end
    end

    local weld = inst:GetAttribute("weld")
    local anchored = inst:GetAttribute("anchored")
    local motor6D = inst:GetAttribute("motor6D")
    if weld then
        assert(anchored == nil and motor6D == nil)
        part.Anchored = false
        local name = kwargs.weldName or "WeldConstraint"
        GaiaShared.create("WeldConstraint", {
            Parent = part,
            Part0 = part,
            Part1 = ref,
            Name = name,
        })
    end
    if anchored then
        assert(weld == nil and motor6D == nil)
        part.Anchored = true
    end
    if motor6D then
        assert(weld == nil and anchored == nil)
        GaiaShared.create("Motor6D", {
            Part0 = charParts.hrp,
            Part1 = part,
            C0 = kwargs.C0,
            C1 = kwargs.C1,
            Name = kwargs.motorName,
            Parent = part,
        })
        inst.Parent = charParts.char
    end
end

-- function module.setFxsCfs(root, charParts)
--     local cf0 = root:GetAttribute("cf0")
--     assert(cf0)
--     local ref
--     if cf0 == "bb" then
--         ref = charParts.boundingBox
--     elseif cf0 == "hrp" then
--         ref = charParts.hrp
--     end
--     root:PivotTo(ref.CFrame)

--     for _, desc in ipairs(root:GetDescendants()) do
--         if not desc:IsA("BasePart") then continue end
--         if RunService:IsStudio() then
--             desc.Transparency = 0.5
--         end
--         local s0 = desc:GetAttribute("s0")
--         if s0 then
--             if s0 == "bb" then
--                 desc.Size = charParts.boundingBox.Size
--             elseif s0 == "hrp" then
--                 desc.Size = charParts.hrp.Size
--             end
--         end
--     end

--     local pp = root.PrimaryPart
--     GaiaShared.create("WeldConstraint", {
--         Parent = pp,
--         Part0 = pp,
--         Part1 = ref,
--     })
-- end

function module.addFxRef(inst, charId, skillName, fxName)
    local RefData = GaiaShared.create("Folder", {Name = "RefData", Parent = inst})
    local name = ("%s_%s_%s"):format(charId, skillName, fxName)
    -- print("NAME S", name)
    GaiaShared.create("StringValue", {
        Name = "RefName",
        Value = ("%s_%s_%s"):format(charId, skillName, fxName),
        Parent = RefData
    })
    CollectionService:AddTag(inst, "EzRef")
end

function module.getFx(charId, skill, fxName, kwargs)
    -- print("NAME C", ("%s_%s_%s"):format(charId, skill, fxName))
    return WaitFor.Ref(("%s_%s_%s"):format(charId, skill, fxName), {
        attempts = 60 * 10,
    })
end

function module.emitBeam(beam)
    beam.Enabled = true
    if beam:GetAttribute("Width0") then beam.Width0 = beam:GetAttribute("Width0") end
    if beam:GetAttribute("Width1") then beam.Width1 = beam:GetAttribute("Width1") end
    if FastMode.isFastMode then
        beam.Enabled = beam:GetAttribute("EnabledFM") or beam.Enabled
        beam.Width0 = beam:GetAttribute("Width0FM") or beam.Width0
        beam.Width1 = beam:GetAttribute("Width1FM") or beam.Width1
    end
end

function module.emitTrail(trail)
    trail.Enabled = true
    if FastMode.isFastMode then
        trail.Enabled = trail:GetAttribute("EnabledFM") or trail.Enabled
    end
end

function module.emitLight(light, duration)
    light.Enabled = true
    if FastMode.isFastMode then
        light.Enabled = light:GetAttribute("EnabledFM") or light.Enabled
    end
end

function module.particleRate(particle, rate, duration)
    particle.Enabled = true
    if FastMode.isFastMode then
        particle.Enabled = particle:GetAttribute("EnabledFM") or particle.Enabled
        particle.Rate = particle:GetAttribute("RateFM") or particle.Rate
    end
end

local charFxValidationCache = {}
local function _shouldRunFx(renderChar, maxRenderDistance)
    if charFxValidationCache[renderChar] then return charFxValidationCache[renderChar] end
    local localPlayer = Players.LocalPlayer
    local localChar = localPlayer.Character
    local distance = (localChar:GetPivot().Position - renderChar:GetPivot().Position).Magnitude
    local res
    if
        not (localChar and localChar.Parent and renderChar and renderChar.Parent)
        or (distance > maxRenderDistance)
    then
        res = false
    else
        res = true
    end

    Promise.delay(2):andThen(function()
        charFxValidationCache[renderChar] = nil
    end)
    charFxValidationCache[renderChar] = res

    return res
end

local defaultRenderDistance = 300
if FastMode.isFastMode or Platforms.getPlatform() == Platforms.Platforms.Mobile then
    defaultRenderDistance = 200
end
-- if RunService:IsStudio() then
--     defaultRenderDistance = 4
-- end
function module.runFxs(root, kwargs)
    if not RunService:IsClient() then
        warn("Only run fxs on client.")
    end
    kwargs = kwargs or {}
    local maid = Maid.new()
    -- if RunService:IsClient() then
    --     local maxRenderDistance = kwargs.maxRenderDistance or defaultRenderDistance
    --     if not _shouldRunFx(renderChar, maxRenderDistance) then return maid end
    -- end
    local disableTbl = {}
    maid:Add(function()
        for i, inst in ipairs(disableTbl) do
            if
                inst:IsA("ParticleEmitter")
                or inst:IsA("Beam")
                or inst:IsA("Trail")
                or inst:IsA("PointLight")
            then
                inst.Enabled = false
            elseif
                inst:IsA("Sound")
            then
                inst:Stop()
            end
        end
    end)
    local function _runFx(inst)
        if inst:IsA("ParticleEmitter") then
            local pEm = inst
            local emitCount = pEm:GetAttribute("EmitCount")
            if FastMode.isFastMode then
                emitCount = pEm:GetAttribute("EmitCountFM") or emitCount
            end
            if emitCount then
                local emitDelay = pEm:GetAttribute("EmitDelay")
                if emitDelay and emitDelay > 0 then
                    task.delay(emitDelay, function()
                        pEm:Emit(emitCount)
                    end)
                else
                    pEm:Emit(emitCount)
                end
            else
                assert(emitCount == nil)
                local emitDelay = pEm:GetAttribute("EmitDelay")
                if emitDelay and emitDelay > 0 then
                    maid:Add(Promise.delay(emitDelay):andThen(function()
                        module.particleRate(pEm)
                    end))
                else
                    module.particleRate(pEm)
                end
                table.insert(disableTbl, pEm)
            end
        elseif inst:IsA("Beam") then
            local beam = inst
            -- local enabled = beam:GetAttribute("enabled")
            -- assert(enabled)
            -- if enabled then
            local EmitDelay = beam:GetAttribute("EmitDelay")

            if EmitDelay and EmitDelay > 0 then
                task.delay(EmitDelay, function()
                    module.emitBeam(beam)
                end)
            else
                module.emitBeam(beam)
            end
            table.insert(disableTbl, beam)

            -- end
            -- local Duration = beam:GetAttribute("Duration")
            -- if Duration then
            --     local Width0 = beam:GetAttribute("Width0")
            --     local Width1 = beam:GetAttribute("Width1")
            --     assert(Width0)
            --     assert(Width1)
            --     local EmitDelay = beam:GetAttribute("EmitDelay")
            --     if EmitDelay and EmitDelay > 0 then
            --         task.delay(EmitDelay, function()
            --             module.emitBeam(beam, Width0, Width1, Duration)
            --         end)
            --     else
            --         module.emitBeam(beam, Width0, Width1, Duration)
            --     end
            -- end
        elseif inst:IsA("Trail") then
                local trail = inst
                local EmitDelay = trail:GetAttribute("EmitDelay")

                if EmitDelay and EmitDelay > 0 then
                    task.delay(EmitDelay, function()
                        module.emitTrail(trail)
                    end)
                else
                    module.emitTrail(trail)
                end
                table.insert(disableTbl, trail)
        elseif inst:IsA("PointLight") then
            local light = inst
            local Delay = light:GetAttribute("EmitDelay")
            -- local enabled = light:GetAttribute("enabled")
            -- assert(enabled)
            if Delay then
                task.delay(Delay, function()
                    module.emitLight(light)
                end)
            else
                module.emitLight(light)
            end
            table.insert(disableTbl, light)
        elseif inst:IsA("Sound") then
            local Delay = inst:GetAttribute("EmitDelay")
            if Delay then
                task.delay(Delay, function()
                    inst:Play()
                end)
            else
                inst:Play()
            end
            table.insert(disableTbl, inst)
        end
    end
    for _, desc in ipairs(root:GetDescendants()) do
        _runFx(desc)
    end
    _runFx(root)
    return maid
end

function module.runCode(renderChar, cb, kwargs)
    assert(RunService:IsClient(), "Only run runCode on client.")

    kwargs = kwargs or {}
    local maid = Maid.new()
    if RunService:IsClient() then
        local maxRenderDistance = kwargs.maxRenderDistance or defaultRenderDistance
        if not _shouldRunFx(renderChar, maxRenderDistance) then return maid end
    end
    maid:Add(cb())
    return maid
end

function module.showModel(root)
    local maid = Maid.new()
    local function _runFx(inst)
        if inst:IsA("BasePart") then
            local transp = inst:GetAttribute("runFxTransp") or 0
            inst.Transparency = transp
            maid:Add(function()
                inst.Transparency = 1
            end)
        end
    end
    maid:Add(function()
        module.hideModel(root)
    end)
    for _, desc in ipairs(root:GetDescendants()) do
        _runFx(desc)
    end
    _runFx(root)
    return maid
end

function module.hideChar(char, charProps)
    local maid = Maid.new()
    maid:Add2(function()
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") or desc:IsA("Decal") then
                local prop = charProps.props[desc]
                if not prop then continue end
                prop:removeCause("Transparency", "Invisible")
            end
            if desc:IsA("Highlight") then
                local prop = charProps.props[desc]
                if not prop then continue end
                prop:removeCause("OutlineTransparency", "Invisible")
            end
        end
    end, "HideAttacker")

    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BasePart") then
            local prop = charProps.props[desc]
            if not prop then continue end
            prop:set("Transparency", "Invisible", 1)
        end
        if desc:IsA("Highlight") then
            local prop = charProps.props[desc]
            if not prop then continue end
            prop:set("OutlineTransparency", "Invisible", 1)
        end
    end
    return maid
end

function module.hideModel(root)
    local maid = Maid.new()
    local function _runFx(inst)
        if inst:IsA("BasePart") then
            local transp = inst:GetAttribute("hideFxTransp") or 1
            inst.Transparency = transp
        end
        if inst:IsA("Beam") or inst:IsA("ParticleEmitter") or inst:IsA("Trail") then
            inst.Enabled = false
        end
    end
    for _, desc in ipairs(root:GetDescendants()) do
        _runFx(desc)
    end
    _runFx(root)
    return maid
end

return module