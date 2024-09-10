local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local MathFunctionals = Mod:find({"Math", "Functionals"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local RankSurfaceGuiC = {}
RankSurfaceGuiC.__index = RankSurfaceGuiC
RankSurfaceGuiC.className = "RankSurfaceGui"
RankSurfaceGuiC.TAG_NAME = RankSurfaceGuiC.className

function RankSurfaceGuiC.new(RootGui)
    local self = {
        RootGui = RootGui,
        _maid = Maid.new(),
    }
    setmetatable(self, RankSurfaceGuiC)

    if not self:getFields() then return end
    self:handleView()

    return self
end

local S = Data.Strings.Strings
local NumberFormatter = Mod:find({"Formatters", "NumberFormatter"})
function RankSurfaceGuiC:handleView()

    local Header = self.EntryProto:Clone()
    Header.LayoutOrder = -1e3
    Header.Rank.Text = "Rank"
    Header.Rank.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.Points.Text = Data.Money.Money[S.Points].prettyName
    Header.Points.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.Visible = true
    Header.Parent = self.EntryContainer


    for id, data in pairs(Data.Ranks.Ranks.idData) do
        local Entry = self.EntryProto:Clone()
        Entry.LayoutOrder = data.LayoutOrder
        Entry.Rank.Text = data.prettyName
        Entry.Rank.TextColor3 = data.color
        Entry.Points.Text = NumberFormatter.numberToEng(data.points)
        Entry.Points.TextColor3 = data.color
        Entry.Name = data.name
        Entry.Visible = true
        Entry.Parent = self.EntryContainer
    end
end

function RankSurfaceGuiC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {
                {"PlayerState", localPlayer},

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.EntryProto = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootGui, refName="EntryProto"})
            if not self.EntryProto then return end

            self.EntryContainer = self.EntryProto.Parent
            self.EntryProto.Parent = nil

            return true
        end,
        keepTrying=function()
            return self.RootGui.Parent
        end,
    })
    return ok
end

function RankSurfaceGuiC:Destroy()
    self._maid:Destroy()
end

return RankSurfaceGuiC