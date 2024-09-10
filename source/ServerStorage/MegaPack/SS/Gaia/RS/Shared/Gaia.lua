local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SignalE = Mod:find({"Signal", "Event"})
local TableUtils = Mod:find({"Table", "Utils"})
local Maid = Mod:find({"Maid"})
local SignalManager = require(ReplicatedStorage.Signals.SignalManager)

local Gaia = {}

function Gaia.create(instName, props)
    props = props or {}
    props = TableUtils.deepCopy(props)
    local inst = Instance.new(instName)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

function Gaia.clone(instProto, props)
    props = props or {}
    props = TableUtils.deepCopy(props)
    local inst = instProto:Clone()
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

function Gaia.set(instance, dataTable)
    local parent = dataTable.Parent
    dataTable.Parent = nil
    for key, data in pairs(dataTable) do
		if typeof(instance[key]) == "table" then
			Gaia.set(instance[key], data)
		else
			instance[key] = data
		end
	end
    instance.Parent = parent
    return instance
end

function Gaia.createIfMissing(instName, props)
    assert(props.Parent, "function requires Parent property.")
    local inst = props.Parent:FindFirstChild(instName)
    if inst then return inst end
    inst = Instance.new(instName)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = parent
    return inst
end

function Gaia.createBindables(root, signals)
    local maid = Maid.new()

    local res = {
        maid = maid,
        signals = {},
    }

    local events = signals.events or {}
    local functions = signals.functions or {}

    local Bindables = root:FindFirstChild("Bindables") or Gaia.create("Folder", {
        Name="Bindables",
    })

    local BindableEvents = Bindables:FindFirstChild("Events") or Gaia.create("Folder", {
        Name="Events",
        Parent=Bindables
    })

    local BindableFunctions = Bindables:FindFirstChild("Functions") or Gaia.create("Folder", {
        Name="Functions",
        Parent=Bindables
    })

    for _, eventName in ipairs(events) do
        if BindableEvents:FindFirstChild(eventName) then
            error(("BindableEvent %s was already created for root %s"):format(eventName, root:GetFullName()))
        end
        local bEvent = maid:Add(Gaia.create("BindableEvent", {Name=eventName, Parent=BindableEvents}))
        local signal = SignalE.new(bEvent)
        maid:Add(SignalManager.add(root, eventName, signal))
        res.signals[eventName] = signal
    end

    for _, name in ipairs(functions) do
        if BindableFunctions:FindFirstChild(name) then
            error(("BindableFunction %s was already created for root %s"):format(name, root:GetFullName()))
        end
        local bFunction = maid:Add(Gaia.create("BindableFunction", {Name=name, Parent=BindableFunctions}))
    end

    Bindables.Parent = root

    return res
end

function Gaia.createBinderSignals(obj, root, signals)
    local maid = Maid.new()
    signals.events = signals.events or {}
    signals.functions = signals.functions or {}

    local res = Gaia.createBindables(root, signals)
    maid:Add(res.maid)

    maid:Add(function()
        for eventName, signal in pairs(res.signals) do
            obj[("%sSE"):format(eventName)]:Destroy()
            obj[("%sSE"):format(eventName)] = nil
        end
    end)
    for eventName, signal in pairs(res.signals) do
        obj[("%sSE"):format(eventName)] = signal
    end
    return maid
end

return Gaia