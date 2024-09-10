local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})

local localPlayer = Players.LocalPlayer

local function setAttributes()

end
setAttributes()

local GamePassBlockC = {}
GamePassBlockC.__index = GamePassBlockC
GamePassBlockC.className = "GamePassBlock"
GamePassBlockC.TAG_NAME = GamePassBlockC.className

function GamePassBlockC.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, GamePassBlockC)

    if not self:getFields() then return end
    self:handleTouch()
    self:setView()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function GamePassBlockC:handleTouch()
    self._maid:Add2(self.Toucher.Touched:Connect(LocalDebounce.playerHrpCooldown(
        function()
            local PurchaseGpRE = ComposedKey.getEvent(ReplicatedStorage, "PurchaseGp")
            if not PurchaseGpRE then return end
            PurchaseGpRE:FireServer(self.gpId)
        end,
        0.5
    )))
end

local Welder = Mod:find({"Welder"})
function GamePassBlockC:setView()
    self.BillboardGui.AlwaysOnTop = true
    self.BillboardGui.MaxDistance = 512
    local shopBlocksData = Data.Shop.ShopGamepassBlocks.idData[self.gpId]
    local color = shopBlocksData.color
    self.Base.Color = color
    self.ProductName.TextColor3 = color
    self.Thumbnail.Visible = false
    self.ProductName.Text = ("%s"):format(shopBlocksData.prettyName)

    local GpModel = self._maid:Add2(ReplicatedStorage.Assets.GamePasses.GamePassBlockThumbmails[shopBlocksData.name]:Clone())
    Welder.weld(GpModel)
    for _, desc in ipairs(GpModel:GetDescendants()) do
        if not desc:IsA("BasePart") then continue end
        desc.CanCollide = false
        desc.CanTouch = false
        desc.CanQuery = false
    end
    GpModel.PrimaryPart.Anchored = true
    local cf0 = self.RootModel:GetPivot()
    GpModel:PivotTo(cf0 + 1 * cf0.UpVector)
    GpModel.Parent = self.RootModel.Model
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function GamePassBlockC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.gpId = self.RootModel:GetAttribute("gpId")
            if not self.gpId then return end

            self.Base = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Base"})
            if not self.Base then return end

            self.Toucher = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Toucher"})
            if not self.Toucher then return end

            self.BillboardGui = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="BillboardGui"})
            if not self.BillboardGui then return end

            self.ProductName = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="ProductName"})
            if not self.ProductName then return end

            self.Thumbnail = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="Thumbnail"})
            if not self.Thumbnail then return end

            local bindersData = {
                {"PlayerState", localPlayer},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
        cooldown=nil
    })
end

function GamePassBlockC:Destroy()
    self._maid:Destroy()
end

return GamePassBlockC