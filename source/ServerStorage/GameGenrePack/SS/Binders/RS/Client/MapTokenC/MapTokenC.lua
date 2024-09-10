local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local localPlayer = Players.LocalPlayer

local MapTokenC = {}
MapTokenC.__index = MapTokenC
MapTokenC.className = "MapToken"
MapTokenC.TAG_NAME = MapTokenC.className

function MapTokenC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, MapTokenC)

    if not self:getFields() then return end
    self:handleClickDetector()

    return self
end

local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
function MapTokenC:handleClickDetector()
    local function update(state)
        if state.st[self.tokenId] then
            self.clickDetector.MaxActivationDistance = 0
            local SelectionBox = self.RootModel:FindFirstChild("SelectionBox")
            if SelectionBox then
                SelectionBox.Adornee = nil
            end
            for _, desc in ipairs(self.RootModel.Model:GetDescendants()) do
                if not desc:IsA("BasePart") then continue end
                desc.Transparency = 1
            end
        else
            self.clickDetector.MaxActivationDistance = 20
            local SelectionBox = self.RootModel:FindFirstChild("SelectionBox")
            if SelectionBox then
                SelectionBox.Adornee = self.RootModel
            end
            for _, desc in ipairs(self.RootModel.Model:GetDescendants()) do
                if not desc:IsA("BasePart") then continue end
                desc.Transparency = 0
            end
        end
    end
    self._maid:Add(self.playerState:getEvent(S.Session, "MapTokens", "update"):Connect(update))
    local state = self.playerState:get(S.Session, "MapTokens")
    update(state)
end

function MapTokenC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            self.tokenId = self.RootModel:GetAttribute("tokenId")
            if not self.tokenId then return end

            self.clickDetector = ComposedKey.getFirstDescendant(self.RootModel, {"ClickDetector"})
            if not self.clickDetector then return end

            local bindersData = {
                {"PlayerState", localPlayer}
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
    })
    return ok
end

function MapTokenC:Destroy()
    self._maid:Destroy()
end

return MapTokenC