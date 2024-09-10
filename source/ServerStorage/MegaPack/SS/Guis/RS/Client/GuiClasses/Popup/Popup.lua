local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local PlayerGui = localPlayer:WaitForChild("PlayerGui")
local PopupsGui = PlayerGui:WaitForChild("PopUps")
local GuiFrame = SharedSherlock:find({"EzRef", "Get"}, {inst=PopupsGui, refName="GuiFrame"})

local Popup = {}
Popup.__index = Popup
Popup.className = "Popup"
Popup.TAG_NAME = Popup.className

function Popup.new()
    local self = {
        _maid = Maid.new(),
    }
    setmetatable(self, Popup)
    self:createGui()

    return self
end

function Popup:createGui()
    self._gui = self._maid:Add(ReplicatedStorage.Assets.Guis.Popup:Clone())
    self._gui.Visible = false
    self._gui.Parent = GuiFrame
end

function Popup:setThumbnail(kwargs)
    local ImageLabel = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self._gui, refName="Thumbnail"})
    if ImageLabel then
        ImageLabel.Image = kwargs.image
    end
end

function Popup:setHeader(kwargs)
    local Header = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self._gui, refName="Header"})
    if Header then
        Header.Text = kwargs.text
    end
end

function Popup:setButtonCenter(kwargs)
    self:setButtonLeft(kwargs)
    self:setButtonRight({disable = true})
end

function Popup:setButtonLeft(kwargs)
    local LeftBtnFr = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self._gui, refName="LeftBtnFr"})
    if not LeftBtnFr then return end
    if kwargs.disable then
        LeftBtnFr:Destroy()
        return
    end
    local Btn = LeftBtnFr.Btn
    local TextLabel = Btn.TextLabel
    TextLabel.Text = kwargs.text or ""
    self._maid:Add(Btn.Activated:Connect(function()
        if kwargs.cb then
            kwargs.cb(self)
        end
        self:Destroy()
    end))
end

function Popup:setButtonRight(kwargs)
    local RightBtnFr = SharedSherlock:find({"EzRef", "GetSync"}, {inst=self._gui, refName="RightBtnFr"})
    if not RightBtnFr then return end
    if kwargs.disable then
        RightBtnFr:Destroy()
        return
    end
    local Btn = RightBtnFr.Btn
    local TextLabel = Btn.TextLabel
    TextLabel.Text = kwargs.text or ""
    self._maid:Add(Btn.Activated:Connect(function()
        if kwargs.cb then
            kwargs.cb(self)
        end
        self:Destroy()
    end))
end

function Popup:activate()
    self._gui.Visible = true
end

function Popup:Destroy()
    self._maid:Destroy()
end

return Popup