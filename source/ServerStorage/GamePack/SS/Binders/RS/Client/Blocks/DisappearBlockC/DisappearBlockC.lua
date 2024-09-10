local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local Promise = Mod:find({"Promise", "Promise"})

local S = Data.Strings.Strings

local DisappearBlockC = {}
DisappearBlockC.__index = DisappearBlockC
DisappearBlockC.className = "DisappearBlock"
DisappearBlockC.TAG_NAME = DisappearBlockC.className

function DisappearBlockC.new(part)
    local self = {
        part = part,
        _maid = Maid.new(),
    }
    setmetatable(self, DisappearBlockC)

    if not self:getFields() then return end
    part.CanTouch = true
    self:handleTouch()

    return self
end

local LocalDebounce = Mod:find({"Debounce", "Local"})
function DisappearBlockC:handleTouch()
    self._maid:Add2(self.part.Touched:Connect(LocalDebounce.playerExecution(function(player, hit)
        if self.disappearing then return end

        local parent = hit.Parent
        if not parent then return end

        local humanoid = parent:FindFirstChild("Humanoid")
        if not humanoid then return end

        if humanoid.Health <= 0 then return end

        self:fadeOut()
    end)))
end

function DisappearBlockC:fadeOut()
    self.disappearing = true

    local disappearTweenDuration = self.part:GetAttribute("DisappearFadeOutDuration") or 2.5
    local tweenInfo = TweenInfo.new(disappearTweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
    local goal = {
        Transparency = 1
    }
    local tween = TweenService:Create(self.part, tweenInfo, goal)
    self._maid:Add(tween.Completed:Connect(function()
        self.part.CanCollide = false
        local invisibleDuration = self.part:GetAttribute("DisappearInvisibleDuration") or 3
        self._maid:Add(Promise.delay(invisibleDuration):andThen(function()
            self.part.CanCollide = true
            self.part.Transparency = 0
            self.disappearing = nil
        end))
    end))
    tween:Play()
end

function DisappearBlockC:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()
            local bindersData = {

            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return self.part.Parent
        end,
    })
    return ok
end

function DisappearBlockC:Destroy()
    self._maid:Destroy()
end

return DisappearBlockC