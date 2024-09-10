local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local GaiaShared = Mod:find({"Gaia", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local BigBen = Mod:find({"Cronos", "BigBen"})
local SignalE = Mod:find({"Signal", "Event"})

local camera = workspace.CurrentCamera

local module = {}

function module.antiGravity(part)
    local maid = Maid.new()

    local attach = maid:Add(GaiaShared.create("Attachment", {
        Name = "AGP",
        Parent = part,
    }))
    local antiGravity = maid:Add(GaiaShared.create("VectorForce", {
        Force = part.AssemblyMass *  workspace.Gravity * Vector3.yAxis,
        ApplyAtCenterOfMass = true,
        RelativeTo = Enum.ActuatorRelativeTo.World,
        Attachment0 = attach,
        Parent = part,
    }))
    return setmetatable(
        {
            attach,
            antiGravity,
            maid = maid,
        },
        {
            __index = maid,
            __string = "antiGravity",
        }
    )

end

function module.waitUntilTravel(inst, distance, interval, kwargs)
    kwargs = kwargs or {}
    interval = interval or 1/60
    local d = 0
    local p0, p1 = inst.Position, inst.Position

    local conn
    conn = BigBen.every(1, "Heartbeat", "frame", true):Connect(function()
        p0 = p1
        p1 = inst.Position
        d += (p1 - p0).Magnitude
        if d >= distance or (kwargs.exitCondition and kwargs.exitCondition()) then
            conn:Disconnect()
            conn = nil
        end
        task.wait(interval)
    end)
    return conn.awaitDisconnectPromise()
end

function module.impulseWithDirectionControl(speed, part)
    local function getMoveDir()
        local zAxis = camera.CFrame.LookVector
        local dot = zAxis:Dot(Vector3.yAxis)
        if dot >= .95 then
            return -camera.CFrame.UpVector
        elseif dot <= -.95 then
            return camera.CFrame.UpVector
        else
            return (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        end
    end
    local moveDirMovingAverage = getMoveDir()
    local maid = Maid.new()

    local bodyVelocity = maid:Add(GaiaShared.create("BodyVelocity", {
        MaxForce = Vector3.new(1e12, 1e12, 1e12),
        P = 1e5,
        Velocity = speed * moveDirMovingAverage,
        Parent = part,
    }))

    local bodyGyro = maid:Add(GaiaShared.create("BodyGyro", {
        MaxTorque = Vector3.new(1e12, 1e12, 1e12),
        D = 100,
        P = 1e5,
        CFrame = CFrame.lookAt(part.Position, part.Position + moveDirMovingAverage),
        Parent = part,
    }))

    maid:Add(BigBen.every(1, "Stepped", "frame", true):Connect(
        function()
            moveDirMovingAverage = getMoveDir()
            bodyVelocity.Velocity = speed * moveDirMovingAverage
            bodyGyro.CFrame = CFrame.lookAt(part.Position, part.Position + moveDirMovingAverage)
        end)
    )

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "impulseWithDirectionControl",
        }
    )
end

function module.impulse(speed, moveDir, part)
    local bodyVelocity = GaiaShared.create("BodyVelocity", {
        MaxForce = Vector3.new(1e12, 1e12, 1e12),
        P = 1e5,
        Velocity = speed * moveDir,
        Parent = part,
    })

    local maid = Maid.new()

    maid:Add(function()
        bodyVelocity:Destroy()
    end)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "impulse",
        }
    )
end

local function setAttributes()
    script:SetAttribute("BackForceTime", 1)
end
setAttributes()
function module.impulseWithBackForce(speed, moveDir, part, backForceTime)
    warn("Not a great idea because a maid with a new force will mess up the force change system")
    warn("Still I'm leaving here as an idea for the future.")
    backForceTime = backForceTime or script:GetAttribute("BackForceTime")
    local bodyVelocity = GaiaShared.create("BodyVelocity", {
        MaxForce = Vector3.new(1e12, 1e12, 1e12),
        P = 1e5,
        Velocity = speed * moveDir,
        Parent = part,
    })

    local maid = Maid.new()

    maid:Add(function()
        bodyVelocity:Destroy()
        local _bodyVelocity = GaiaShared.create("BodyVelocity", {
            MaxForce = Vector3.new(1e12, 1e12, 1e12),
            P = 1e5,
            Velocity = Vector3.zero,
            Parent = part,
        })
        task.delay(backForceTime, function()
            _bodyVelocity:Destroy()
        end)
    end)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "impulse",
        }
    )
end

function module.impulseWithFixLook(speed, moveDir, part, lookDir)
    local bodyGyro = GaiaShared.create("BodyGyro", {
        MaxTorque = Vector3.new(1e15, 1e15, 1e15),
        D = 100,
        P = 1e5,
        CFrame = CFrame.lookAt(part.Position, part.Position + lookDir),
        Parent = part,
    })

    local bodyVelocity = GaiaShared.create("BodyVelocity", {
        MaxForce = Vector3.new(1e12, 1e12, 1e12),
        P = 1e5,
        Velocity = speed * moveDir,
        Parent = part,
    })

    local maid = Maid.new()

    maid:Add(function()
        bodyVelocity:Destroy()
        bodyGyro:Destroy()
    end)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "impulseWithFixLook",
        }
    )
end

function module.rotateToTarget(part, lookDir, torqueFilter)
    torqueFilter = torqueFilter or Vector3.new(1, 1, 1)
    local bodyGyro = GaiaShared.create("BodyGyro", {
        MaxTorque = Vector3.new(1e15, 1e15, 1e15) * torqueFilter,
        D = 100,
        P = 1e5,
        CFrame = CFrame.lookAt(part.Position, part.Position + lookDir),
        Parent = part,
    })


    local maid = Maid.new()

    maid:Add(function()
        bodyGyro:Destroy()
    end)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "rotateToTarget",
        }
    )
end

function module.impulseWithFixLookAndNoAutoRotate(speed, moveDir, part, lookDir, humanoid)
    local bodyGyro = GaiaShared.create("BodyGyro", {
        MaxTorque = Vector3.new(1e15, 1e15, 1e15),
        D = 100,
        P = 1e5,
        CFrame = CFrame.lookAt(part.Position, part.Position + lookDir),
        Parent = part,
    })

    local bodyVelocity = GaiaShared.create("BodyVelocity", {
        MaxForce = Vector3.new(1e12, 1e12, 1e12),
        P = 1e5,
        Velocity = speed * moveDir,
        Parent = part,
    })

    humanoid.AutoRotate = false

    local maid = Maid.new()

    maid:Add(function()
        humanoid.AutoRotate = true
        bodyVelocity:Destroy()
        bodyGyro:Destroy()
    end)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "impulseWithFixLookAndNoAutoRotate",
        }
    )
end

function module.float(part, position, lookDir, humanoid, kwargs)
    kwargs = kwargs or {}
    local bodyGyro = GaiaShared.create("BodyGyro", {
        MaxTorque = Vector3.new(1e15, 1e15, 1e15),
        D = 100,
        P = 1e5,
        CFrame = CFrame.lookAt(part.Position, part.Position + lookDir),
        Parent = part,
    })

    local bodyPosition = GaiaShared.create("BodyPosition", {
        D = kwargs.bPD or 100,
        MaxForce = 1e6 * Vector3.new(1, 1, 1),
        P = kwargs.bPP or 1e3,
        Position = position,
        Parent = part,
    })

    if humanoid then
        humanoid.AutoRotate = false
    end

    local maid = Maid.new()

    maid:Add(function()
        if humanoid then
            humanoid.AutoRotate = true
        end
        bodyPosition:Destroy()
        bodyGyro:Destroy()
    end)

    return setmetatable(
        {
            maid = maid,
            bodyPosition = bodyPosition,
            bodyGyro = bodyGyro,
        },
        {
            __index = maid,
            __string = "float",
        }
    )
end

function module.goTo(partGoing, target, lockDir, bpP, bpD, kwargs)
    kwargs = kwargs or {}
    local maid = Maid.new()
    local returnTbl = {maid = maid}
    local bodyGyro
    if lockDir then
        bodyGyro = maid:Add(GaiaShared.create("BodyGyro", {
            MaxTorque = Vector3.new(1e15, 1e15, 1e15),
            D = 100,
            P = 1e5,
            CFrame = CFrame.lookAt(partGoing.Position, target:GetPivot().Position * Vector3.new(1, 0, 1) + partGoing.Position * Vector3.new(0, 1, 0)),
            Parent = partGoing,
        }))
        returnTbl.bodyGyro = bodyGyro
    end

    local bodyPosition = maid:Add(GaiaShared.create("BodyPosition", {
        D = bpD,
        MaxForce = 1e6 * Vector3.new(1, 1, 1),
        P = bpP,
        Position = target:GetPivot().Position,
        Parent = partGoing,
    }))
    returnTbl.bodyPosition = bodyPosition

    local reachSignal = maid:Add(SignalE.new())

    local timeout = kwargs.timeout or 3
    returnTbl.reachPromise = maid:Add(Promise.fromEvent(reachSignal))

    maid:Add(returnTbl.reachPromise
    :timeout(timeout)
    :finally(function()
        if maid.isDestroyed then return end
        maid:Remove("Tracking")
    end))

    local threshold = kwargs.threshold or 4
    maid:Add2(BigBen.every(1, "Heartbeat", "frame", false):Connect(function()
        if bodyGyro then
            bodyGyro.CFrame = CFrame.lookAt(partGoing.Position, target:GetPivot().Position  * Vector3.new(1, 0, 1)  + partGoing.Position * Vector3.new(0, 1, 0))
        end
        bodyPosition.Position = target:GetPivot().Position

        -- print(partGoing:GetFullName())
        -- print(target:GetFullName())
        -- print((partGoing.Position - target.Position).Magnitude)
        if (partGoing.Position - target.Position).Magnitude < threshold then
            reachSignal:Fire()
        end
    end), "Tracking")

    return setmetatable(
        returnTbl,
        {
            __index = maid,
            __string = "goTo",
        }
    )
end

function module.goTo2(partGoing, target, lockDir, kwargs)
    kwargs = kwargs or {}
    local maid = Maid.new()
    local returnTbl = {maid = maid}
    local alignOrientation
    if lockDir then
        local data = kwargs.orientation
        alignOrientation = maid:Add(GaiaShared.create("AlignOrientation", {
            Attchment0 = data.Attchment0 or  maid:Add(GaiaShared.create("Attachmenet", {Parent = partGoing})),
            Attchment1 = data.Attchment1 or  maid:Add(GaiaShared.create("Attachmenet", {Parent = target})),
            MaxAngularVelocity = data.MaxAngularVelocity or 100,
            MaxTorque = data.MaxTorque or 100,
            Responsiveness = data.Responsiveness or 10,
            Parent = partGoing,
        }))
        returnTbl.alignOrientation = alignOrientation
    end

    local alignPosition
    do
        local data = kwargs.position
        alignPosition = maid:Add(GaiaShared.create("AlignPosition", {
            Attchment0 = data.Attchment0 or  maid:Add(GaiaShared.create("Attachmenet", {Parent = partGoing})),
            Attchment1 = data.Attchment1 or  maid:Add(GaiaShared.create("Attachmenet", {Parent = target})),
            ApplyAtCenterOfMass = data.ApplyAtCenterOfMass or false,
            MaxForce = data.MaxForce or 1000,
            MaxVelocity = data.MaxForce or 100,
            Responsiveness = data.Responsiveness or 10,
            Parent = partGoing,
        }))
        returnTbl.alignPosition = alignPosition
    end

    if kwargs.frameCb then
        local data = kwargs.frameCb
        maid:Add(BigBen.every(data._tick or 1, "Heartbeat", "frame", false):Connect(data.cb))
    end

    return setmetatable(
        returnTbl,
        {
            __index = maid,
            __string = "goTo2",
        }
    )
end

function module.linearImpulse(part, force)
    local maid = Maid.new()
    part:ApplyImpulse(force)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "linearImpulse",
        }
    )

end

function module.angularImpulse(part, torque)
    local maid = Maid.new()
    part:ApplyAngularImpulse(torque)

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "angularImpulse",
        }
    )
end

function module.partImpulse(part, force, torque)
    assert(force ~= nil or torque ~= nil, "Force and Torque cannot be nil.")
    local maid = Maid.new()
    if force then
        part:ApplyImpulse(force)
    end
    if torque then
        part:ApplyAngularImpulse(torque)
    end

    return setmetatable(
        {
            maid = maid,
        },
        {
            __index = maid,
            __string = "partImpulse",
        }
    )

end

return module