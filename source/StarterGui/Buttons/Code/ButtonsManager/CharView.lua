local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local Maid = Mod:find({"Maid"})

local gui = script:FindFirstAncestorWhichIsA("LayerCollector")

local View = {}
View.__index = View
View.className = "View"
View.TAG_NAME = View.className

function View.new(ctrl)
    local self = {
        _maid = Maid.new(),
        ctrl = ctrl,
    }
    setmetatable(self, View)
    if not self:getFields() then return end
    return self
end

function View:getFields()
    local ok = WaitFor.GetAsync({
        getter=function()
            local bindersData = {}
            if not BinderUtils.addBindersToTable(self, bindersData) then return end

            return true
        end,
        keepTrying=function()
            return gui.Parent
        end,
        cooldown=1
    })
    return ok
end

function View:Destroy()
    self._maid:Destroy()
end

return View