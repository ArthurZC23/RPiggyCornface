local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Bach = Mod:find({"Bach", "Bach"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")
local Background = SharedSherlock:find({"EzRef", "Get"}, {inst=gui, refName="Background"})

local localPlayer = Players.LocalPlayer
local binderPlayerState = SharedSherlock:find({"Binders", "getBinder"}, {tag="PlayerState"})
local playerState = SharedSherlock:find({"Binders", "waitForInstToBind"}, {binder=binderPlayerState, inst=localPlayer})

local View = {}
View.__index = View
View.className = "View"
View.TAG_NAME = View.className

function View.new()
    local self = {}
    setmetatable(self, View)

    self:handlePurchaseBackground()

    return self
end

function View:handlePurchaseBackground()
    local function update(state)
        -- if state.onPurchase then
        --     -- Background.Active = true
        --     -- Background.Visible = true
        --     task.delay(0.2, function()
        --         Bach:play("RbxPurchasePrompt", Bach.SoundTypes.SfxGui)
        --     end)
        -- else
        --     -- Background.Visible = false
        --     -- Background.Active = false
        -- end
    end
    playerState:getEvent(S.Session, "Gui", "setPurchaseState"):Connect(update)
    local state = playerState:get(S.Session, "Gui")
    update(state)
end

function View:Destroy()
    self._maid:Destroy()
end

return View