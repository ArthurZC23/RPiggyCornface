local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local CharUtils = Mod:find({"CharUtils", "CharUtils"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local CharGuisC = {}
CharGuisC.__index = CharGuisC
CharGuisC.className = "CharGuis"
CharGuisC.TAG_NAME = CharGuisC.className

function CharGuisC.new(char)
    local isLocalChar, player = CharUtils.isLocalChar(char)
    if not isLocalChar then return end

    local self = {
        player = player,
        char = char,
        _maid = Maid.new(),
        controllers = {},
        views = {},
    }
    setmetatable(self, CharGuisC)

    if not self:getFields() then return end
    self:initGuis()
    return self
end

function CharGuisC:initGuis()
    local function init(gui)
        -- Respawn guis appear before this is destroyed.
        if self._maid.isDestroyed then return end
        -- print(("Load Gui %s"):format(gui:GetFullName()))
        for _, desc in ipairs(gui:GetDescendants()) do
            if desc:IsA("ModuleScript") and desc.Name == "RunCharGui" then
                task.spawn(function()
                    -- print(("Run %s"):format(desc:GetFullName()))
                    local mod = require(desc)
                    self._maid:Add(mod.run(self))
                    -- print(("Run Finished %s"):format(desc:GetFullName()))
                end)
            end
        end
    end

    self._maid:Add2(self.PlayerGui.ChildAdded:Connect(init), "InitGui")
    for _, gui in ipairs(self.PlayerGui:GetChildren()) do
        task.spawn(init, gui)
    end
end

function CharGuisC:addController(id, controller)
    if self.controllers[id] then
        error(("Gui Controller id %s is already taken by %s."):format(controller.className, self.controllers[id].className))
    end
    self.controllers[id] = controller
end

function CharGuisC:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"PlayerState", self.player},
                {"CharState", self.char},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            self.PlayerGui = self.player:FindFirstChild("PlayerGui")
            if not self.PlayerGui then return end

            return true
        end,
        keepTrying=function()
            return self.char.Parent
        end,
        cooldown=1
    })
    return ok
end

function CharGuisC:Destroy()
    self._maid:Destroy()
end

return CharGuisC