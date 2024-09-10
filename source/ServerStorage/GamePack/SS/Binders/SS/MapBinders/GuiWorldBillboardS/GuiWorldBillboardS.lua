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

local function setAttributes()

end
setAttributes()

local GuiWorldBillboardS = {}
GuiWorldBillboardS.__index = GuiWorldBillboardS
GuiWorldBillboardS.className = "GuiWorldBillboard"
GuiWorldBillboardS.TAG_NAME = GuiWorldBillboardS.className

function GuiWorldBillboardS.new(RootModel)
    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, GuiWorldBillboardS)

    if not self:getFields() then return end

    return self
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function GuiWorldBillboardS:setView(worldId)
    self.GuiWorldName.PixelsPerStud = 100
    self.GuiWorldReward.PixelsPerStud = 100
    local worldData = Data.Worlds.Worlds.idData[worldId]
    self.WorldName.Text = worldData.prettyName.Text
    self.WorldRewardFrame.Amount.Text = worldData.reward.value
    self.WorldRewardFrame.ImageLabel.Image = Data.Money.Money[S.Money_1].thumbnail
end


function GuiWorldBillboardS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            self.GuiWorldName = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="GuiWorldName"})
            if not self.GuiWorldName then return end

            self.GuiWorldReward = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="GuiWorldReward"})
            if not self.GuiWorldReward then return end

            self.WorldName = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="WorldName"})
            if not self.WorldName then return end

            self.WorldRewardFrame = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self.RootModel, refName="WorldRewardFrame"})
            if not self.WorldRewardFrame then return end

            local bindersData = {

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

function GuiWorldBillboardS:Destroy()
    self._maid:Destroy()
end

return GuiWorldBillboardS