local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local Promise = Mod:find({"Promise", "Promise"})

local function setAttributes()
    script:SetAttribute("v0x", 120)
    script:SetAttribute("v0y", 7)
end
setAttributes()


local LandmineC = {}
LandmineC.__index = LandmineC
LandmineC.className = "Landmine"
LandmineC.TAG_NAME = LandmineC.className

function LandmineC.new(RootModel)
    if not RootModel:FindFirstAncestor("Workspace") then return end

    local self = {
        RootModel = RootModel,
        _maid = Maid.new(),
    }
    setmetatable(self, LandmineC)

    if not self:getFields() then return end
    self:loadSounds()
    self:handleTouch()

    return self
end

function LandmineC:loadSounds()
    self.Sounds = BinderUtils.loadSounds({
        Notification = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.LandmineNotification,
            parent = self.Ball,
        },
        Explosion1 = {
            proto = ReplicatedStorage.Assets.Sounds.Sfx.Explosion1,
            parent = self.Body,
        },
    })
    self.Sounds.Explosion1.PlayOnRemove = true
end

local GaiaShared = Mod:find({"Gaia", "Shared"})
function LandmineC:playExplosionFx()
    local Explosion = GaiaShared.create("Explosion", {
        Name = "Explosion",
        DestroyJointRadiusPercent = 0,
        BlastPressure = 0,
        BlastRadius = 0,
        Position = self.Body.Position,
        Parent = workspace.Tmp,
    })

    Promise.delay(3):andThen(function()
        Explosion:Destroy()
    end)

end

function LandmineC:playAntecipationFx()
    self.Ball.Color = Color3.fromRGB(255, 0, 0)
    self.Sounds.Notification:Play()
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function LandmineC:handleTouch()
    self._maid:Add2(self.Toucher.Touched:Connect(LocalDebounce.playerLimbExecutionCooldown(
        function(_, hrp)
            local dir = ((hrp.Position - self.Body.Position) * Vector3.new(1, 0, 1)).Unit
            local char = hrp.Parent
            local ChatMSE = SharedSherlock:find({"Bindable", "sync"}, {root = char, signal = "ChatM"})
            if not ChatMSE then return end

            self:playAntecipationFx()
            task.wait(0.5)
            ChatMSE:Fire(script:GetAttribute("v0x"), script:GetAttribute("v0y"), dir)
            self:playExplosionFx()
            self._maid:Remove("Touch")
            self.RootModel:Destroy()
        end,
        1,
        "Hrp"
    )), "Touch")
end


function LandmineC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()

            self.Body = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "Body"})
            if not self.Body then return end

            self.Ball = ComposedKey.getFirstDescendant(self.RootModel, {"Model", "Ball"})
            if not self.Ball then return end

            self.Toucher = ComposedKey.getFirstDescendant(self.RootModel, {"Skeleton", "Toucher"})
            if not self.Toucher then return end

            local bindersData = {

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

function LandmineC:Destroy()
    self._maid:Destroy()
end

return LandmineC