local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Promise = Mod:find({"Promise", "Promise"})
local TableUtils = Mod:find({"Table", "Utils"})
local BinderManager = Mod:find({"Binder", "Manager"})
local Data = Mod:find({"Data", "Data"})
local ErrorReport = Mod:find({"ErrorReport", "ErrorReport"})

local function getDefaultsParameters()
    local attemptTimeout = 3
    local cooldown = 1 / 60
    local attempts = attemptTimeout / cooldown
    return {cooldown=cooldown, attempts=attempts}
end
local defaults = getDefaultsParameters()

local function getAttemptsAndCooldown(kwargs)
    local cooldown = kwargs.cooldown or defaults.cooldown
    local attempts = kwargs.attempts or defaults.attempts
    if RunService:IsStudio() and Data.Studio.Studio.waitFor.alwaysUseDefault then
        cooldown = defaults.cooldown
        attempts = defaults.attempts
    end

    return attempts, cooldown
end

local function validateKeepTrying(keepTrying, traceback)
    if keepTrying() == nil then
        ErrorReport.report("Server", ("keepTrying returns nil on first call. Fix it.\n %s"):format(traceback), "error")
    end
end

local module = {}

function module.Get(kwargs)
    kwargs = kwargs or {}
    assert(kwargs.keepTrying)
    assert(kwargs.getter)

    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    local keepTrying = kwargs.keepTrying
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)

    return Promise.try(function()
        local val = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = kwargs.getter,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if val then return val end
    end)
end

function module.GetAsync(kwargs)
    kwargs = kwargs or {}
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    assert(kwargs.keepTrying)
    local keepTrying = kwargs.keepTrying
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    return SharedSherlock:find({"WaitFor", "Val"}, {
        getter = kwargs.getter,
        keepTrying = keepTrying,
        cooldown = cooldown,
        attempts = attempts,
        traceback = traceback,
    })
end

function module.Value(tbl, composedKey, kwargs)
    kwargs = kwargs or {}
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    assert(kwargs.keepTrying)
    local keepTrying = kwargs.keepTrying
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    return Promise.try(function()
        local val = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = function()
                if kwargs._debug then print("Debug") end
                return ComposedKey.get(tbl, composedKey)
            end,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if val then return val end
        error(("Did not find table %s composed key %s."):format(tostring(tbl), TableUtils.stringify(composedKey)))
    end)
end

function module.Child(inst, childName, kwargs)
    kwargs = kwargs or {}
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    local keepTrying = kwargs.keepTrying or function() return inst.Parent end
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    return Promise.try(function()
        local val = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = function()
                return inst:FindFirstChild(childName)
            end,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if val then return val end
        error(("Did not find inst %s child %s."):format(inst:GetFullName(), childName))
    end)
end

function module.Desc(inst, composedKey, kwargs)
    kwargs = kwargs or {}
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    local keepTrying = kwargs.keepTrying or function() return inst.Parent end
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    return Promise.try(function()
        local val = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = function()
                return ComposedKey.getFirstDescendant(inst, composedKey)
            end,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if val then return val end
        error(("Did not find inst %s desc %s."):format(inst:GetFullName(), TableUtils.stringify(composedKey)))
    end)
end

function module.Ref(refName, kwargs)
    kwargs = kwargs or {}
    local inst = kwargs.inst or workspace
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    local keepTrying = kwargs.keepTrying or function() return inst.Parent end
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    return module.Child(inst, "References"):andThenPromise(function(ReferencesF)
        local referenceV = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = function()
                local reference = ComposedKey.getFirstDescendant(ReferencesF, {("%s"):format(refName)})
                if not reference then
                    return
                end
                return reference.Value
            end,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if referenceV then return referenceV end
        error("Did not find ref.")
    end)
end

function module.BObjs(data)
    local promises = {}
    for i = 1, #data do
        promises[i] = module.BObj(unpack(data[i]))
    end
    return Promise.all(promises)
end

function module.BObj(inst, tag, kwargs)
    kwargs = kwargs or {}
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    local keepTrying = kwargs.keepTrying or function() return inst.Parent end
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    if kwargs._debug then
        print(attempts, cooldown)
    end
    return module.Binder(tag):andThenPromise(function(binder)
        local obj = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = function()
                return binder:getObj(inst)
            end,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if obj then return obj end
        error(("Did not find obj %s for inst %s."):format(tag, inst:GetFullName()))
    end)
end

function module.Binder(tag, kwargs)
    kwargs = kwargs or {}
    local binder
    task.delay(40, function()
        if not binder then error(("Binder %s probably doesn't exist."):format(tag)) end
    end)
    local attempts, cooldown = getAttemptsAndCooldown(kwargs)
    local keepTrying = kwargs.keepTrying or function() return true end
    local traceback = debug.traceback(nil, 2)
    validateKeepTrying(keepTrying, traceback)
    return Promise.try(function()
        binder = SharedSherlock:find({"WaitFor", "Val"}, {
            getter = function()
                return BinderManager.binders[tag]
            end,
            keepTrying = keepTrying,
            cooldown = cooldown,
            attempts = attempts,
            traceback = traceback,
        })
        if binder then return binder end
        error(("Did not find binder %s."):format(tag))
    end)
end

return module