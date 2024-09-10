local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})

local module = {}

function module.runTexturesInDecal(part, texturesData, clientData, kwargs)
    kwargs = kwargs or {}
    kwargs.debug = kwargs.debug or {}
    clientData = clientData or {}
    local tweens = {}
    local maid = Maid.new()
    local decals = {}
    maid:Add(function()
        if not kwargs.debug.freezeAtIdx then
            for _, decal in ipairs(decals) do
                decal:Destroy()
            end
        end
    end)

    return Promise.try(function()
        for j, data in ipairs(texturesData) do
            if kwargs.debug.freezeAtIdx and (kwargs.debug.freezeAtIdx > j) then continue end
            local cData = clientData[j] or {}
            local cDecalsData = cData.decals or {}
            local cTweens = cData.tweens or {}
            local numCurrentDecals = #decals
            local decalsData = data.decals
            local requiredDecals = #decalsData
            for i = numCurrentDecals + 1, requiredDecals do
                decals[i] = GaiaShared.create("Decal", {
                    Name = tostring(i),
                    Parent = part,
                })
            end

            for i=1, #decals do
                if decalsData[i] then
                    TableUtils.setInstance(decals[i], decalsData[i])
                    if cDecalsData[i] then
                        TableUtils.setInstance(decals[i], cDecalsData[i])
                    end
                    if cTweens[i] then
                        if tweens[i] then
                            tweens[i]:Pause()
                            tweens[i]:Destroy()
                        end
                        local tweenInfo, goals = unpack(cTweens[i])
                        tweens[i] = TweenService:Create(decals[i], tweenInfo, goals)
                        tweens[i]:Play()
                    end
                else
                    decals[i].Transparency = 1
                end
            end
            local promise = maid:Add(
                Promise.delay(data.duration or (1/60)):catch(function(err)
                    warn(tostring(err))
                end),
                "cancel",
                "textureHold"
            )
            local ok = promise:await()
            if not ok then
                return
            end
        end
    end)
        :catch(function (err)
            warn(tostring(err))
        end)
        :finally(function ()
            maid:Destroy()
        end)
end

function module.getDuration(texturesData)
    local totalDuration = 0
    for j, data in ipairs(texturesData) do
        totalDuration += data.duration or (1/60)
    end
    return totalDuration
end

function module.createTexturesInARow(partProto, texturesData, space)
    for i, data in ipairs(texturesData) do
        local part = partProto:Clone()
        local cf = part:GetPivot()
        space = space or 4
        part:PivotTo(cf + (i) * (space + part.Size.X) * part.CFrame.RightVector)
        part.Name = tostring(i)

        for _, decalData in ipairs(data.decals) do
            local decal = GaiaShared.create("Decal", decalData)
            decal.Parent = part
        end

        part.Parent = partProto.Parent
    end
    partProto:Destroy()
end

return module