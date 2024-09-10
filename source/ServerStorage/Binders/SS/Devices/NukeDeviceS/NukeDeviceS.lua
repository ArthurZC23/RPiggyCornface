local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local JobScheduler = Mod:find({"DataStructures", "JobScheduler"})
local Queue = Mod:find({"DataStructures", "Queue"})
local NotificationStreamRE = ComposedKey.getAsync(ReplicatedStorage, {"Remotes", "Events", "NotificationStream"})
local Bach = Mod:find({"Bach", "Bach"})
local Promise = Mod:find({"Promise", "Promise"})

local function setAttributes()

    if RunService:IsStudio() then

    end
end
setAttributes()

local NukeDeviceS = {}
NukeDeviceS.__index = NukeDeviceS
NukeDeviceS.className = "NukeDevice"
NukeDeviceS.TAG_NAME = NukeDeviceS.className

function NukeDeviceS.new(RootModel)
    local self = {
        _maid = Maid.new(),
        RootModel = RootModel,
    }
    setmetatable(self, NukeDeviceS)

    if not self:getFields() then return end
    self:addScheduler()

    return self
end

function NukeDeviceS:addScheduler()
    self.scheduler = JobScheduler.new(
        function(job)
            local kwargs = job[1]
            self:startNuke(kwargs)
        end,
        "cooldown",
        {
            queueProps = {
                {},
                {
                    maxSize=100,
                    fullQueueHandler=Queue.FullQueueHandlers.DiscardNew,
                    queueType=Queue.QueueTypes.FirstLastIdxs,
                }
            },
            schedulerProps = {
                cooldownFunc = function() return 5 end
            }
        }
    )
end

function NukeDeviceS:scheduleNuke(kwargs)
    self.scheduler:pushJob({kwargs})
end

function NukeDeviceS:explosion(kwargs)
    local maid = Maid.new()
    local res = {
        maid = maid,
    }

    local Explosion = kwargs.Explosion
    local ExplosionSfx = Explosion.NukeExplosion
    maid:Add(function()
        Bach:stop(ExplosionSfx, Bach.SoundTypes.Sfx3D)
    end)
    Bach:play(ExplosionSfx, Bach.SoundTypes.Sfx3D)
    Explosion.Transparency = 0
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
    local goal = {
        Size = Vector3.new(512, 512, 512)
    }
    local tween = maid:Add(TweenService:Create(Explosion, tweenInfo, goal))
    tween:Play()
    res.promise = Promise.fromEvent(tween.Completed)
    return res
end

function NukeDeviceS:startNuke(kwargs)
    local maid = self._maid:Add2(Maid.new(), "Nuke")

    Promise.try(function()
        local maidNukeRelease = self._maid:Add2(Maid.new(), "NukeRelease")
        NotificationStreamRE:FireAllClients({
            Text = ("%s launched a nuke!"):format(kwargs.player.Name),
            TextColor3 = Color3.fromRGB(200, 0, 0),
        },
        {
            Root = "TopCenter",
        })
        maidNukeRelease:Add(function()
            Bach:stop("NukeRelease", Bach.SoundTypes.Sfx)
        end)
        Bach:play("NukeRelease", Bach.SoundTypes.Sfx)
        local NukeFolder = maid:Add(ReplicatedStorage.Assets.Models.Nuke:Clone())
        NukeFolder.Parent = workspace.Tmp
        local Nuke = maidNukeRelease:Add(NukeFolder.Nuke)
        local Explosion = NukeFolder.Explosion.PrimaryPart
        local NukeDefaultTarget = NukeFolder.NukeDefaultTarget

        local char = kwargs.player.Character

        if char and char.Parent then
            Explosion:PivotTo(Explosion:GetPivot().Rotation + char:GetPivot().Position)
        else
            Explosion:PivotTo(Explosion:GetPivot().Rotation + NukeDefaultTarget:GetPivot().Position)
        end
        Nuke:PivotTo(CFrame.lookAlong(Explosion:GetPivot().Position + 160 * Vector3.yAxis, -Vector3.yAxis))
        local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
        local goal = {
            CFrame = Nuke:GetPivot().Rotation + Explosion:GetPivot().Position,
        }
        local tweenRocket = maidNukeRelease:Add(TweenService:Create(Nuke.PrimaryPart, tweenInfo, goal))
        tweenRocket:Play()
        kwargs.Nuke = Nuke
        kwargs.Explosion = Explosion
        return maidNukeRelease:Add(Promise.fromEvent(tweenRocket.Completed))
    end)
    :andThen(function()
        self._maid:Remove("NukeRelease")
        kwargs.Explosion = kwargs.Explosion
        local res2 = self:explosion(kwargs)
        maid:Add(res2.maid)
        return res2.promise
    end)
    :timeout(20)
    :finally(function()
        self._maid:Remove("Nuke")
        for _, player in ipairs(Players:GetPlayers()) do
            if player == kwargs.player then continue end
            local char = player.Character
            if not (char and char.Parent) then continue end
            local DamageKillSE = SharedSherlock:find({"Bindable", "sync"}, {root = char, signal = "DamageKill"})
            if not DamageKillSE then return end
            DamageKillSE:Fire()
        end
    end)
end

function NukeDeviceS:getFields()
    local ok = SharedSherlock:find({"WaitFor", "Val"}, {
        getter=function()

            return true
        end,
        keepTrying=function()
            return self.RootModel.Parent
        end,
    })
    return ok
end

function NukeDeviceS:Destroy()
    self._maid:Destroy()
end

return NukeDeviceS