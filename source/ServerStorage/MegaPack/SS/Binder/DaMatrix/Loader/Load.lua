local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local FastSpawn = Mod:find({"FastSpawn"})

local BinderF = ReplicatedStorage:WaitForChild("MegaPack"):WaitForChild("Binder")
local Binder = require(BinderF:WaitForChild("Shared"):WaitForChild("Binder"))
local BindersManager = require(BinderF:WaitForChild("Shared"):WaitForChild("BindersManager"))

local Binders = ServerStorage.Binders.SS

local function bindCollection(inst)
    -- print(inst:GetFullName())
    if not (inst:IsA("ModuleScript") and inst.Name == "BinderClass") then return end

    local Class = require(inst)

    if BindersManager.binders[Class.TAG_NAME] then
        warn(("Bindable class for tag %s is being repeated on server."):format(Class.TAG_NAME))
        warn(("New binder: %s"):format(inst:GetFullName()))
        local oldBinder = BindersManager.binders[Class.TAG_NAME]
        warn(("Old binder: %s"):format(oldBinder._classModulePath))
    end

    -- print("New binder: ", Class.TAG_NAME)
    local binder = Binder.new(Class.TAG_NAME, Class, inst:GetFullName())
    binder:load()
    BindersManager.binders[Class.TAG_NAME] = binder
    -- print("New binder loaded: ", Class.TAG_NAME)
end

local function run()
	Binders.DescendantAdded:Connect(bindCollection)
    for _, desc in ipairs(Binders:GetDescendants()) do
        FastSpawn(bindCollection, desc)
	end
end
run()

local module = {}

return module