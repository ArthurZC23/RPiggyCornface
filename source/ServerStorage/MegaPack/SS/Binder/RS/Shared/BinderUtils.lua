local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local StringsUtils = Mod:find({"Strings", "Utils"})
local TableUtils = Mod:find({"Table", "Utils"})

local BinderUtils = {}

local function _typeCheck(func)
    return function (binder, inst)
        assert(type(binder) == "table" and binder.className == "Binder", "Binder must be binder")
        assert(typeof(inst) == "Instance", "inst parameter must be instance")
        func(binder, inst)
    end
end

local maxAttempts = 180
if RunService:IsStudio() then
    -- maxAttempts = 10
end
function BinderUtils.getBinders(bindersData, kwargs)
    local attempts = kwargs.attempts
    local binders = {}
    for _, data in ipairs(bindersData) do
        local binderName = data[1]
        local inst
        if typeof(data[2]) == "function" then
            inst = data[2](binders, data[3])
        else
            inst = data[2]
        end
        local key = data[4] or StringsUtils.firstLowerCase(binderName)
        binders[key] = SharedSherlock:find({"Binders", "getBinder"}, {tag=binderName}):getObj(inst)
        if not binders[key] then
            if RunService:IsStudio() then
                if attempts > maxAttempts then
                    local traceback = debug.traceback(nil, 2)
                    warn(("Could not get binder %s for %s\n%s"):format(binderName, inst:GetFullName(), traceback))
                end
            end
            return nil, key
        end
    end
    return binders
end

local BinderManager = Mod:find({"Binder", "Manager"})
function BinderUtils.getObj(binderName, instance)
    local binder = BinderManager.binders[binderName]
    if not binder then return end
    return binder:getObj(instance)
end

function BinderUtils.loadSounds(soundsData)
    local sounds = {}
    for soundName, soundData in pairs(soundsData) do
        local sound = soundData.proto:Clone()
        sound.Parent = soundData.parent
        sounds[soundName] = sound
    end
    return sounds
end

function BinderUtils.setInterface(obj, interfaceImplementation, methods)
    for _, m in ipairs(methods) do
        obj[m] = function(interface, ...)
            return interfaceImplementation[m](interfaceImplementation, ...)
        end
    end
end

function BinderUtils.getCharEvents(char)
    local charId = char:GetAttribute("uid")
    local charEvents = ComposedKey.getFirstDescendant(ReplicatedStorage, {"CharsEvents", charId})
    return charEvents
end

function BinderUtils.addBindersToTable(tbl, bindersData, kwargs)
    kwargs = kwargs or {}
    local _debug = kwargs._debug
    tbl._BinderUtilsaddBindersToTableAttempts = tbl._BinderUtilsaddBindersToTableAttempts or 0
    tbl._BinderUtilsaddBindersToTableAttempts += 1

    local binders, missingBinderName = BinderUtils.getBinders(bindersData, {
        attempts = tbl._BinderUtilsaddBindersToTableAttempts,
    })
    if not binders then
        if _debug then
            local traceback = debug.traceback(nil, 2)
            task.defer(function()
                error(("Binder %s was not found.\n%s"):format(missingBinderName, traceback))
            end)
        end
        return
    end
    TableUtils.complementUnrestrained(tbl, binders)

    tbl._BinderUtilsaddBindersToTableAttempts = nil
    return binders
end

function BinderUtils.addRemotesToTable(tbl, remoteF, eventsNames)
    local events = {}
    for _, ev in ipairs(eventsNames) do
        local event = ComposedKey.getFirstDescendant(remoteF, {"Remotes", "Events", ev})
        if not event then return end
        events[("%sRE"):format(ev)] = event
    end
    TableUtils.complementUnrestrained(tbl, events)
    return events
end

function BinderUtils.addRemotesFunctionsToTable(tbl, remoteF, funcNames)
    local functions = {}
    for _, funcName in ipairs(funcNames) do
        local rf = ComposedKey.getFirstDescendant(remoteF, {"Remotes", "Functions", funcName})
        if not rf then return end
        functions[("%sRF"):format(funcName)] = rf
    end
    TableUtils.complementUnrestrained(tbl, functions)
    return functions
end

function BinderUtils.initComponents(rootTable, Components, kwargs)
    kwargs = kwargs or {}
    local maid = kwargs.maid or rootTable._maid
    local accessTable = kwargs.accessTable or rootTable
    for cName, cClass in pairs(Components) do
        accessTable[cName] = maid:AddComponent(cClass.new(rootTable, kwargs))
        if not accessTable[cName] then return false end
    end
    return true
end

function BinderUtils.findFirstAncestor(tag, inst)
	local current = inst.Parent
	while current do
		local obj = SharedSherlock:find({"Binder", "getInstObj"}, {inst=inst, tag=tag})
		if obj then return obj end
		current = current.Parent
	end
	return nil
end

function BinderUtils.findFirstTaggedAncestor(tag, inst)
	local current = inst.Parent
	while current do
        print("Current ", current:GetFullName())
		if CollectionService:HasTag(current, tag) then
			return current
		end
		current = current.Parent
	end
	return nil
end

function BinderUtils.findFirstChild(inst, binder)
	for _, child in pairs(inst:GetChildren()) do
		local obj = binder:getObj(child)
		if obj then
			return obj
		end
	end
	return nil
end
BinderUtils.findFirstChild = _typeCheck(BinderUtils.findFirstChild)

function BinderUtils.getChildren(inst, binder)
	local objects = {}
	for _, item in pairs(inst:GetChildren()) do
		local obj = binder:getObj(item)
		if obj then
			table.insert(objects, obj)
		end
	end
	return objects
end
BinderUtils.getChildren = _typeCheck(BinderUtils.getChildren)

function BinderUtils.getDescendants(binder, inst)
	local objects = {}
	for _, item in pairs(inst:GetDescendants()) do
		local obj = binder:getObj(item)
		if obj then
			table.insert(objects, obj)
		end
	end
	return objects
end
BinderUtils.getChildren = _typeCheck(BinderUtils.getChildren)

function BinderUtils.mapBinderListToTable(bindersList)
	assert(type(bindersList) == "table", "bindersList must be a table of binders")

	local tags = {}
	for _, binder in pairs(bindersList) do
		tags[binder:GetTag()] = binder
	end
	return tags
end

function BinderUtils.getObjsFromInstanceList(tagsMap, instanceList)
	local objects = {}

	for _, instance in pairs(instanceList) do
		for _, tag in pairs(CollectionService:GetTags(instance)) do
			local binder = tagsMap[tag]
			if binder then
				local obj = binder:getObj(instance)
				if obj then
					table.insert(objects, obj)
				end
			end
		end
	end

	return objects
end

function BinderUtils.getChildrenOfBinders(bindersList, inst)
	assert(type(bindersList) == "table", "bindersList must be a table of binders")
	assert(typeof(inst) == "Instance", "Parent parameter must be instance")

	local tagsMap = BinderUtils.mapBinderListToTable(bindersList)
	return BinderUtils.getMappedFromList(tagsMap, inst:GetChildren())
end

function BinderUtils.getLinkedChildren(binder, linkName, inst)
	local seen = {}
	local objects = {}
	for _, item in pairs(inst:GetChildren()) do
		if item.Name == linkName and item:IsA("ObjectValue") and item.Value then
			local obj = binder:getObj(item.Value)
			if obj then
				if not seen[obj] then
					seen[obj] = true
					table.insert(objects, obj)
				else
					warn(("[BinderUtils.getLinkedChildren] - Double linked children at %q"):format(item:GetFullName()))
				end
			end
		end
	end
	return objects
end

return BinderUtils