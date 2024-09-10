local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Props = Mod:find({"Props", "Props"})
local CharPropsDefault = Mod:find({"Props", "CharPropsDefault"})
local RigLimbs = Mod:find({"PlayerUtils", "RigLimbs"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})

local CharPropsC = {}
CharPropsC.__index = CharPropsC
CharPropsC.className = "CharProps"
CharPropsC.TAG_NAME = CharPropsC.className

function CharPropsC.new(char)
    local self = {
        _maid = Maid.new(),
        char = char,
        props = {},
    }
    setmetatable(self, CharPropsC)

    if not self:getFields() then return end
    if CharUtils.isLocalChar(self.char) then
        self:handleServerPropSetters()
    end
    self:addProps()

    return self
end

function CharPropsC:handleServerPropSetters()
    self.charState:getEvent(S.Session, "Props", "removeClientProps"):Connect(function(_, action)
        for _, data in ipairs(action.t) do
            self.props[data.o]:removeCause(data.p, data.c)
        end
    end)
    self.charState:getEvent(S.Session, "Props", "setClientProps"):Connect(function(_, action)
        for _, data in ipairs(action.t) do
            self.props[data.o]:set(data.p, data.c, data.v)
        end
    end)
end

function CharPropsC:_addDescendantsProps()
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

        -- local transpDefault = SharedSherlock:find({"WaitFor", "Val"}, {
        --     getter=function()
        --         return desc:GetAttribute("transpDefault")
        --     end,
        --     keepTrying=function()
        --         return desc:IsDescendantOf(self.char)
        --     end,
        -- })
        -- desc:SetAttribute("transpDefault", transpDefault or 1)

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

function CharPropsC:_addCharProps()
    self.props[self.char] = Props.new(self.char)
    local defaultSetter = CharPropsDefault.setters["Char"]
    if defaultSetter then
        defaultSetter(self.props[self.char], self.char)
    end

end

function CharPropsC:addProps()
    self:_addDescendantsProps()
    self:_addCharProps()

    self._maid:Add(function()
        for _, obj in pairs(self.props) do
            obj:Destroy()
        end
    end)
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharPropsC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            do
                local bindersData = {
                    {"CharParts", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end
            if CharUtils.isLocalChar(self.char) then
                local bindersData = {
                    {"CharState", self.char},
                }
                if not BinderUtils.addBindersToTable(self, bindersData) then return end
            end
            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
    })
end

function CharPropsC:Destroy()
    self._maid:Destroy()
end

return CharPropsC