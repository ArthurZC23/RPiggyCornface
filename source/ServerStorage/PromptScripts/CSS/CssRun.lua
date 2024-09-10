local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Data = ServerStorage.Data.SS.Data

local Promise = require(ReplicatedStorage.Promise.Shared.Promise:Clone())
local Maid = require(ServerStorage.MegaPack.SS.Cleaner.RS.Shared.Janitor.Janitor:Clone())

local maid = Maid.new()
Promise.try(function()
    local ModProto = Data.CSS.CSS
    local CSSMod = maid:Add(ModProto:Clone())
    CSSMod.Parent = ModProto.Parent
    local CssStyles = require(CSSMod).styles

    local function applyStyle(inst, cssData)
        if inst:IsA("BasePart") then
            inst.Color = cssData.color or inst.Color
            if cssData.colorTarget then
                inst.Color = inst.Color:Lerp(cssData.colorTarget, cssData.colorAlpha)
            end
        end
    end
    
    for _, desc in ipairs(game:GetDescendants()) do
        local cssId = desc:GetAttribute("CSSClass")
        if not cssId then continue end
        local cssData = CssStyles[cssId]
        if not cssData then
            warn(("Instance %s with css style %s don't have data."):format(desc:GetFullName(), cssId))
            continue
        end
        local styles = {cssData}
        local parentStyle = cssData.parentStyle
        while parentStyle do
            local _cssData = CssStyles[parentStyle]
            table.insert(styles, _cssData)
            parentStyle = _cssData.parentStyle
        end
        for i = #styles, 1, -1 do
            local _cssData = styles[i]
            applyStyle(desc, _cssData)
        end
    end
end)
:catchAndPrint()
:finally(function()
    maid:Destroy()
end)
