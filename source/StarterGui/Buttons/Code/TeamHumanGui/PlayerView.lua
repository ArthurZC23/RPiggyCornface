local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local Frames = {
    MapTokensFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="MapTokensFrame"}),
    LivesFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="LivesFrame"}),
    HideFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="HideFrame"}),
    -- ShopBtn = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="ShopBtn"}),
    -- Money_1Frame = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Money_1Frame"}),
}

local View = {}
View.__index = View
View.className = "TeamHumanGuiView"
View.TAG_NAME = View.className

local function setAttributes()

end
setAttributes()

function View.new(controller)
    local self = {
        _maid = Maid.new(),
        controller = controller,
        teamGui = "human",
    }
    setmetatable(self, View)
    if not self:getFields() then return end

    return self
end

function View:open()
    local maid = self._maid:Add2(Maid.new(), "Open")
    maid:Add2(function()
        for _, Frame  in pairs(Frames) do
            Frame.Visible = false
        end
    end)
    for _, Frame  in pairs(Frames) do
        Frame.Visible = true
    end
end

function View:close()
    self._maid:Remove("Open")
end

function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function View:Destroy()
    self._maid:Destroy()
end

return View