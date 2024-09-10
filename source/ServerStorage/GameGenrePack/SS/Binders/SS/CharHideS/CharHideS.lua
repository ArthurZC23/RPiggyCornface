local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local GaiaServer = Mod:find({"Gaia", "Server"})
local S = Data.Strings.Strings
local PlayerUtils = Mod:find({"PlayerUtils", "PlayerUtils"})

local function setAttributes()

end
setAttributes()

local CharHideS = {}
CharHideS.__index = CharHideS
CharHideS.className = "CharHide"
CharHideS.TAG_NAME = CharHideS.className

function CharHideS.new(char)
    if char:HasTag("PlayerMonster") then return end

    local self = {
        _maid = Maid.new(),
        char = char,
    }
    setmetatable(self, CharHideS)

    if not self:getFields() then return end
    self:createRemotes()
    self:handleCamouflageModel()
    self:handleHide()
    self:handleHideRequest()

    return self
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function CharHideS:handleCamouflageModel()
    local function update(state)
        local maid = self._maid:Add2(Maid.new(), "setCamouflageModelUpdate")
        local id = state.eq
        local data = Data.MonsterSkins.MonsterSkins.idData[id]
        local Model = maid:Add2(data.camouflageModel:Clone())
        Model.Name = "Camouflage"
        GaiaShared.create("WeldConstraint", {
            Part0 = Model.PrimaryPart,
            Part1 = self.charParts.hrp,
            Parent = Model.PrimaryPart,
        })
        local cf0 =
            self.charParts.hrp.CFrame
            - (self.charParts.leftUpperLeg.Size
            + self.charParts.leftLowerLeg.Size
            + self.charParts.leftFoot.Size) * Vector3.yAxis
        Model:PivotTo(cf0)
        Model.Parent = self.char
    end
    self._maid:Add(self.playerState:getEvent(S.Stores, "MonsterSkins", "eq"):Connect(update))
    local state = self.playerState:get(S.Stores, "MonsterSkins")
    update(state)
end

function CharHideS:handleHide()
    local function update(state)
        if state.on then
            local maid = self._maid:Add2(Maid.new(), "CharPropsHide")
            local cause = "Hide"

            local monsterSkinState = self.playerState:get(S.Stores, "MonsterSkins")
            local skinId = monsterSkinState.eq
            local data = Data.MonsterSkins.MonsterSkins.idData[skinId]
            local Camouflage = self.char:FindFirstChild("Camouflage")
            if Camouflage and data.tags then
                maid:Add2(function()
                    for _, tag in ipairs(data.tags) do
                        Camouflage:RemoveTag(tag)
                    end
                end)
                for _, tag in ipairs(data.tags) do
                    Camouflage:AddTag(tag)
                end
            end

            do
                local prop = self.charProps.props[self.charParts.humanoid]
                prop:set("WalkSpeed", cause, 0)
                prop:set("JumpPower", cause, 0)
                maid:Add2(function()
                    prop:removeCause("WalkSpeed", cause)
                    prop:removeCause("JumpPower", cause)
                end)
            end

            maid:Add2(function()
                for _, desc in ipairs(self.char:GetDescendants()) do
                    if (desc:IsA("BasePart") or desc:IsA("Decal")) then
                        local prop = self.charProps.props[desc]
                        if not prop then continue end
                        prop:removeCause("Transparency", cause)
                    elseif desc:IsA("ParticleEmitter") then
                        desc.Enabled = false
                    end
                end
            end)

            for _, desc in ipairs(self.char:GetDescendants()) do
                if (desc:IsA("BasePart") or desc:IsA("Decal")) then
                    local transp = 1
                    if desc:GetAttribute("Camouflage") then
                        transp = 0
                    end
                    local prop = self.charProps.props[desc]
                    if not prop then continue end
                    prop:set("Transparency", cause, transp)
                elseif desc:IsA("ParticleEmitter") then
                    desc.Enabled = true
                end
            end
        else
            self._maid:Remove("CharPropsHide")
        end
    end
    self._maid:Add(self.charState:getEvent(S.Session, "Hide", "setHide"):Connect(update))
    local state = self.charState:get(S.Session, "Hide")
    update(state)
end

function CharHideS:handleHideRequest()
    self._maid:Add2(self.HideCharRE.OnServerEvent:Connect(function(plr)
        if plr ~= self.player then return end
        local hideState = self.charState:get(S.Session, "Hide")
        do
            local action = {
                name = "setHide",
                value = not hideState.on,
            }
            self.charState:set(S.Session, "Hide", action)
        end
    end))
end

function CharHideS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.char, {
        events = {"HideChar"},
        functions = {},
    }))
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CharHideS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.player = PlayerUtils:GetPlayerFromCharacter(self.char)
            if not self.player then return end

            local bindersData = {
                {"CharProps", self.char},
                {"CharParts", self.char},
                {"CharState", self.char},
                {"PlayerState", self.player},
            }
            if not BinderUtils.addBindersToTable(self, bindersData, {_debug = nil}) then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=nil
    })
end

function CharHideS:Destroy()
    self._maid:Destroy()
end

return CharHideS