local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Props = Mod:find({"Props", "Props"})
local CharPropsDefault = Mod:find({"Props", "CharPropsDefault"})
local RigLimbs = Mod:find({"PlayerUtils", "RigLimbs"})

local CharPropsS = {}
CharPropsS.__index = CharPropsS
CharPropsS.className = "CharProps"
CharPropsS.TAG_NAME = CharPropsS.className

function CharPropsS.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
        props = {},
    }
    setmetatable(self, CharPropsS)

    if not self:getFields() then return end
    self:addProps()

    return self
end

function CharPropsS:_addDescendantsProps()
    local function add(desc)
        if not (
            desc:IsA("BasePart")
            or desc:IsA("Humanoid")
            -- or (desc:IsA("Decal") and desc:GetAttribute("hasProp"))
            or (desc:IsA("Decal"))
            or (desc:IsA("Texture") and desc:GetAttribute("hasProp"))
            or (desc:IsA("Beam") and desc:GetAttribute("hasProp"))
            or (desc:IsA("Highlight") and desc:GetAttribute("hasProp"))
            or (desc:IsA("TextLabel") and desc:GetAttribute("hasProp"))
        ) then return end

        self.props[desc] = Props.new(desc)

        if desc:GetAttribute("transpDefault") then
        elseif
            desc.Name == "HumanoidRootPart" or desc.Name == "RootPart"
        then
            desc:SetAttribute("transpDefault", 1)
        elseif
            desc:GetAttribute("charLimb")
            or (desc.Name == "face" and desc.Parent == self.charParts.head)
            or desc:FindFirstAncestorOfClass("Accessory")
        then
            desc:SetAttribute("transpDefault", 0)
            desc:SetAttribute("charVisiblePart", true)
        elseif desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
            desc:SetAttribute("transpDefault", 1)
        end
        CharPropsDefault.setters.Any(desc, self.props[desc], self.char)
        local defaultSetter = CharPropsDefault.setters[desc.Name]
        if defaultSetter then
            defaultSetter(self.props[desc])
        end
    end

    local function remove(desc)
        local obj = self.props[desc]
        if obj and (not obj._maid.isDestroyed) then obj:Destroy() end
    end

    self._maid:Add(self.char.DescendantAdded:Connect(add))
    self._maid:Add(self.char.DescendantRemoving:Connect(remove))
    for _, desc in ipairs(self.char:GetDescendants()) do
       add(desc)
    end
end

function CharPropsS:_addCharProps()
    self.props[self.char] = Props.new(self.char)
    local defaultSetter = CharPropsDefault.setters["Char"]
    if defaultSetter then
        defaultSetter(self.props[self.char], self.char)
    end

end

function CharPropsS:addProps()
    self:_addDescendantsProps()
    self:_addCharProps()

    self._maid:Add(function()
        for _, obj in pairs(self.props) do
            obj:Destroy()
        end
    end)
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharPropsS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"CharParts", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
end

function CharPropsS:Destroy()
    self._maid:Destroy()
end

return CharPropsS