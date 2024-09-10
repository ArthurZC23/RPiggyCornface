local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = script:FindFirstAncestor("Shared")
local Sherlock = require(Shared.Sherlock)

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Promise = Mod:find({"Promise", "Promise"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})
local Cronos = Mod:find({"Cronos", "Cronos"})

local SignalsManager = {
    Events = {},
    Functions = {},
}

local searchSpace = {}

local Maid = Mod:find({"Maid"})
local SignalE = Mod:find({"Signal", "Event"})
local SignalF = Mod:find({"Signal", "Function"})
local BinderManager = Mod:find({"Binder", "Manager"})
local SingletonManager = Mod:find({"Singleton", "Manager"})


local function getNumAttemps(setAttempts, maxAttemps)
    maxAttemps = maxAttemps or 90
    local studioAttempts = 10
    local attempts = setAttempts or maxAttemps
    if setAttempts then
        attempts = setAttempts
    elseif RunService:IsStudio() then
        attempts = studioAttempts
    else
        attempts = maxAttemps
    end
    return attempts
end

local function validateKeepTrying(keepTrying, traceback)
    traceback = traceback or "Traceback: nil"
    if keepTrying() == nil then
        ErrorReport.report("Server", ("keepTrying returns nil on first call. Fix it.\n %s"):format(traceback), "error")
    end
end

searchSpace.WaitFor = {
    Val = function(kwargs)
        local getter = kwargs.getter
        local keepTrying = kwargs.keepTrying
        local cd = kwargs.cooldown or 1/60
        local traceback = kwargs.traceback or ""
        validateKeepTrying(keepTrying)
        local attempts = getNumAttemps(kwargs.attempts)
        local count = 0
        local t0 = Cronos:getTime()
        local warningFlag = false
        local errorFlag = false
        repeat
            count += 1
            local val, err = getter(kwargs)
            local isFinished = (val or (not keepTrying(kwargs)))
            if isFinished then return val end

            local totalTime = Cronos:getTime() - t0
            local debugMsg = kwargs.debugMsg or ""
            err = err or "No detailed error message."

            local str1 = "WaitFor Val has not loaded yet"
            local str2 = ("Total Time: %s"):format(totalTime)
            local str3 = ("Error: %s"):format(err)
            local str4 = ("Extra information: %s"):format(debugMsg)
            local str5 = ("Traceback: %s"):format(debug.traceback(nil, 2))
            local msg = table.concat({str1, str2, str3, str4, str5}, "\n\n")
            if RunService:IsStudio() then
                local warnLimit = 5
                if totalTime > warnLimit and (not warningFlag) then
                    warningFlag = true
                    warn(msg)
                end
            else
                --if count == 4 * attempts then
                -- after 120 seconds is simply not loading, just wasting cpu.
                -- local errorLimit = 120
                local errorLimit = 90
                if totalTime > errorLimit and (not errorFlag) then
                    errorFlag = true
                    ErrorReport.report("", msg, "error")
                    if cd < 10 then
                        cd = 10
                    else
                        cd = 100
                    end
                end
            end
            task.wait(cd)

            if not keepTrying(kwargs) then return end
        until isFinished
    end,
    ChildInstance = function(kwargs)
        -- based on https://devforum.roblox.com/t/x-waitforchild-y-leaks-lua-thread-if-x-is-destroyed/177408/3?u=bachatronic
        local parent = kwargs.parent
        local childName = kwargs.childName
        local child = parent:FindFirstChild(childName)
        if child then return child end

        local traceback = debug.traceback(nil, 2)

        local maid = Maid.new()

        local resolveEvent = maid:Add(Instance.new("BindableEvent"))

        maid:Add(parent.ChildAdded:Connect(function(child_)
            if child_.Name == childName then resolveEvent:Fire(child_) end
        end))

        maid:Add(parent.AncestryChanged:Connect(function()
            if not parent:IsDescendantOf(game) then resolveEvent:Fire() end
        end))

        maid:Add(Promise.delay(3):andThen(
            function()
                warn(("Shared Sherlock ChildInstance for parent %s and child %s is still yield.")
                    :format(parent.Name, childName))
                warn(traceback)
            end),
            "cancel"
        )

        resolveEvent.Event:Connect(function() maid:Destroy() end)

        return resolveEvent.Event:Wait()
    end,
    DescendantInstance = function(kwargs)
        local parent = kwargs.parent
        local descName = kwargs.descName
        local desc = parent:FindFirstChild(descName, true)
        if desc then return desc end

        local traceback = debug.traceback(nil, 2)

        local maid = Maid.new()

        local resolveEvent = maid:Add(Instance.new("BindableEvent"))

        maid:Add(parent.DescendantAdded:Connect(function(desc)
            if desc.Name == descName then resolveEvent:Fire(desc) end
        end))

        maid:Add(parent.AncestryChanged:Connect(function()
            if not parent:IsDescendantOf(game) then resolveEvent:Fire() end
        end))

        maid:Add(Promise.delay(3):andThen(
            function()
                warn(("Shared Sherlock DescendantInstance for parent %s and desc %s is still yield.")
                    :format(parent.Name, descName))
                warn(traceback)
            end),
            "cancel"
        )

        resolveEvent.Event:Connect(function() maid:Destroy() end)

        return resolveEvent.Event:Wait()
    end,
    AncestorInstance = function(kwargs)
        local inst = kwargs.inst
        local ancestorName = kwargs.ancestorName
        local ancestor = inst:FindFirstAncestor(ancestorName, true)
        if ancestor then return ancestor end

        local traceback = debug.traceback(nil, 2)

        local maid = Maid.new()

        local resolveEvent = maid:Add(Instance.new("BindableEvent"))

        maid:Add(inst.AncestryChanged:Connect(function(_, parent)
            if parent.Name == ancestorName then resolveEvent:Fire(parent) end
            if not parent then resolveEvent:Fire() end
        end))

        maid:Add(Promise.delay(3):andThen(
            function()
                warn(("Shared Sherlock AncestorInstance for inst %s and desc %s is still yield.")
                    :format(inst.Name, ancestorName))
                warn(traceback)
            end),
            "cancel"
        )

        resolveEvent.Event:Connect(function() maid:Destroy() end)

        return resolveEvent.Event:Wait()
    end,
}

searchSpace.ObjRef = {
    GetSync = function(kwargs)
        local reference = ComposedKey.getFirstDescendant(kwargs.inst, {"ObjRefs", ("%s"):format(kwargs.refName)})
        if not reference then return end
        local value = reference.Value

        return value
    end,
}

searchSpace.EzRef = {
    GetV1 = function(kwargs)
        local refName = kwargs.refName
        local inst = kwargs.inst
        local ReferencesF = inst:FindFirstChild("References")
        local reference = ReferencesF:WaitForChild(("%s"):format(refName))
        if not reference.Value then
            reference.Changed:Wait()
        end
        return reference.Value
    end,
    Get = function(kwargs)
        local refName = kwargs.refName
        local inst = kwargs.inst or workspace
        local ReferencesF = inst:FindFirstChild("References")
        local cd = kwargs.cooldown or 1 / 60
        local referenceV = searchSpace.WaitFor.Val({
            getter = function()
                local reference = ReferencesF:FindFirstChild(("%s"):format(refName))
                if not reference then
                    -- print(inst:GetFullName(), refName)
                    return
                end
                return reference.Value
            end,
            keepTrying = function()
                return inst.Parent
            end,
            cooldown = cd,
        })
        return referenceV
    end,
    GetSync = function(kwargs)
        local refName = kwargs.refName
        local inst = kwargs.inst or workspace
        local reference = ComposedKey.getFirstDescendant(inst, {"References", ("%s"):format(refName)})
        if not reference then return end
        local value = reference.Value

        return value
    end,
    GetPromise = function(kwargs)
        local refName = kwargs.refName
        local inst = kwargs.inst or workspace
        local ReferencesF = inst:FindFirstChild("References")
        local cd = kwargs.cooldown or 1 / 60
        return Promise.try(function()
            local referenceV = searchSpace.WaitFor.Val({
                getter = function()
                    local reference = ReferencesF:FindFirstChild(("%s"):format(refName))
                    if not reference then
                        -- print(inst:GetFullName(), refName)
                        return
                    end
                    return reference.Value
                end,
                keepTrying = function()
                    return inst.Parent
                end,
                cooldown = cd,
            })
            if referenceV then return referenceV end
            error("Did not find ref.")
        end)
    end,
}

searchSpace.FindFirst = {
    AncestorChild = function(kwargs)
        local ancestorChildName = kwargs.ancestorChildName
        local ancestor = kwargs.inst
        local ancestorChild
        repeat
            ancestor = ancestor.Parent
            if not ancestor then return end
            ancestorChild = ancestor:FindFirstChild(ancestorChildName)
        until ancestorChild
        return ancestorChild
    end,
}

searchSpace.Binders = {
    find = function(kwargs)
        local tag = kwargs.tag
        local binder = BinderManager.binders[tag]
        return binder
    end,
    findClass = function(kwargs)
        local tag = kwargs.tag
        local binder = BinderManager.binders[tag]
        if not binder then return end
        return binder._Class
    end,
    getClassBag = function(kwargs)
        local class = searchSpace.Binders.findClass(kwargs)
        if not class then return end
        local bag = kwargs.bag or "bag"
        return bag
    end,
    getInstById = function(kwargs)
        local class = searchSpace.Binders.findClass(kwargs)
        if not class then return end
        local bag = kwargs.bag or "bag"
        return class[bag][kwargs.id]
    end,
    getObjPromise = function(kwargs)
        return Promise.try(function()
            if not kwargs.cd then kwargs.cooldown = 1 / 60 end
            local binder = searchSpace.Binders.getBinder(kwargs)
            kwargs.binder = binder
            local obj = searchSpace.Binders.waitForInstToBind(kwargs)
            return obj
        end)
    end,
    getBinder = function(kwargs)
        local tag = kwargs.tag
        local cd = kwargs.cooldown or 1
        local attempts = getNumAttemps(kwargs.attempts)
        -- This will definetly finish if the tag name is correct
        local binder

        if RunService:IsStudio() then
            task.delay(40, function()
                if not binder then error(("Binder %s probably doesn't exist."):format(tag)) end
            end)
        end

        binder = searchSpace.WaitFor.Val({
            getter = function()
                local _binder = BinderManager.binders[tag]
                return _binder
            end,
            keepTrying = function()
                return true
            end,
            cooldown = cd,
            attempts = attempts,
            debugMsg = ("Binder %s is taking too long to load. Maybe it doesn't exist."):format(tag),
        })
        return binder
    end,
    getBinderSync = function(kwargs)
        return BinderManager.binders[kwargs.tag]
    end,
    getInstObj = function(kwargs)
        local binder = BinderManager.binders[kwargs.tag]
        if not binder then return end
        return binder:getObj(kwargs.inst)
    end,
    waitForInstToBindV1 = function(kwargs)
        local binder = kwargs.binder
        local inst = kwargs.inst
        assert(inst ~= game, "inst cannot be game. Use waitForGameToBind instead.")
        local signal = binder:getClassAddedSignal()
        local obj = binder:getObj(inst)
        -- Will this work with signal defered?
        if not obj then
            local inst_
            -- what if class doesn't bind? This will halt indefenetly
            while inst.Parent and (inst_ ~= inst) do
                obj, inst_ = signal:Wait() -- Is this a problem as being used multiple times?
            end
        end
        return obj
    end,
    waitForInstToBindV2 = function(kwargs)
        local binder = kwargs.binder
        local inst = kwargs.inst
        assert(inst ~= game, "inst cannot be game. Use waitForGameToBind instead.")
        local obj = searchSpace.WaitFor.Val({
            getter=function()
                return binder:getObj(inst)
            end,
            keepTrying=function()
                return inst.Parent
            end
        })
        return obj
    end,
    waitForInstToBind = function(kwargs)
        local binder = kwargs.binder
        local inst = kwargs.inst
        assert(inst ~= game, "inst cannot be game. Use waitForGameToBind instead.")
        local cd = kwargs.cooldown or 1
        local attempts = getNumAttemps(kwargs.attempts)
        local obj = searchSpace.WaitFor.Val({
            getter = function()
                return binder:getObj(inst)
            end,
            keepTrying = function()
                return inst.Parent
            end,
            cooldown = cd,
            attempts = attempts,
            debugMsg = ("Instance %s binder %s is not loading."):format(inst:GetFullName(), binder:getTag())
        })
        return obj
    end,
    waitForGameToBind = function(kwargs)
        local binder = kwargs.binder
        local inst = kwargs.inst
        assert(inst == game, ("inst %s is not game."):format(inst:GetFullName()))
        local cd = kwargs.cooldown or 1
        local attempts = getNumAttemps(kwargs.attempts)
        local obj = searchSpace.WaitFor.Val({
            getter = function()
                return binder:getObj(inst)
            end,
            keepTrying = function()
                return true
            end,
            cooldown = cd,
            attempts = attempts,
        })
        return obj
    end,
}

searchSpace.Bach = {
    AudioPlayers = function()
        return {}
    end,
    Playlists = {
        Ambience = function()
            return {}
        end,
        Soundtrack = function()
            local SoundtracksF = workspace.Audio.Soundtracks
            return {
                Default = SoundtracksF.Default:GetChildren(),
                Arena = SoundtracksF.Arena:GetChildren(),
                Obby = SoundtracksF.Obby:GetChildren(),
            }
        end
    }
}

searchSpace.Gui = function(kwargs)
    local gui = kwargs.gui
    local refName = kwargs.refName
    local rootGui = gui:FindFirstAncestorWhichIsA("LayerCollector")
    local References = gui.Code.References
    local reference = References:WaitForChild(("%s"):format(refName))
    return reference.Value
end

local SignalManager = require(ReplicatedStorage.Signals.SignalManager)
searchSpace.Bindable = {
    async = function(kwargs)
        ComposedKey.getBEventAsync(kwargs.root, kwargs.signal)
        return searchSpace.Bindable.sync(kwargs)
    end,
    sync = function(kwargs)
        return SignalManager.get(kwargs.root, kwargs.signal)
    end,
}

searchSpace.Singletons = {
    async = function(kwargs)
        local name = kwargs.name
        local cd = kwargs.cooldown or 1
        local attempts = getNumAttemps(kwargs.attempts)
        -- This will definetly finish if the singleton name is correct
        local singleton = searchSpace.WaitFor.Val({
            getter = function()
                local singleton = SingletonManager.singletons[name]
                return singleton
            end,
            keepTrying = function()
                return true
            end,
            cooldown = cd,
            attempts = attempts,
            debugMsg = ("Singleton %s is taking too long to load. Maybe it doesn't exist."):format(name),
        })
        return singleton
    end,
}

local HttpService = game:GetService("HttpService")
searchSpace.Serialization = {
    SerializeAttribute = function(kwargs)
        kwargs.inst:SetAttribute(kwargs.name, HttpService:JSONEncode(kwargs.val))
    end,
    DeserializeAttribute = function(kwargs)
        local data = kwargs.inst:GetAttribute(kwargs.name)
        if data == nil then return data end
        return HttpService:JSONDecode(data)
    end,
}

return Sherlock.new(searchSpace)