local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local CharData = Data.Char.Char

local module = {}

local cause = "Default"
module.setters = {
    Any = function(inst, props, char)
        if inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture") then
            local transpDefault = SharedSherlock:find({"WaitFor", "Val"}, {
                getter=function()
                    local transpDefault = inst:GetAttribute("transpDefault")
                    if not transpDefault then return end
                    return transpDefault
                end,
                keepTrying=function()
                    return inst:IsDescendantOf(char)
                end,
            })
            if RunService:IsServer() then
                props:set("Transparency", cause, transpDefault)
            end
        end
        if inst:IsA("BasePart") then
            props:set("Anchored", cause, inst.Anchored)
            props:set("Material", cause, inst.Material)
            props:set("Color", cause, inst.Color)
        end
        if inst:IsA("MeshPart") then
            props:set("TextureID", cause, inst.TextureID)
        end
        if inst:IsA("TextLabel") then
            props:set("Text", cause, "")
        end
    end,
    Humanoid = function(props)
        props:set("WalkSpeed", cause, CharData.speed.default)
        props:set("JumpPower", cause, CharData.jumpPower.default)
    end,
    Char = function(props, char)

    end,
    Highlight = function(props, char)
        props:set("FillColor", cause, Color3.fromRGB(0, 0, 0))
        props:set("FillTransparency", cause, 1)
        props:set("OutlineColor", cause, Color3.fromRGB(0, 0, 0))
        props:set("OutlineTransparency", cause, 0)
    end,
}

return module