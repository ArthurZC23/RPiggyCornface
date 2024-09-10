local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local BinderUtils = Mod:find({"Binder", "Utils"})

local RootF = script:FindFirstAncestor("Car")

local CarC = {}
CarC.__index = CarC
CarC.className = "Car"
CarC.TAG_NAME = CarC.className

function CarC.new(rootModel)
    local carMId = rootModel:GetAttribute("CarModelId")
    local self = {
        rootModel = rootModel,
        carMId = carMId,
        _maid = Maid.new(),
    }
    setmetatable(self, CarC)

    if not self:getFields() then return end
    -- if not BinderUtils.initComponents(self, Components) then return end

    return self
end

local WaitFor = Mod:find({"WaitFor", "WaitFor"})
function CarC:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"Seats", self.rootModel},
            }
            if not BinderUtils.addBindersToTable(self, bindersData) then return end
            return true
        end,
        keepTrying=function()
            return self.rootModel.Parent
        end,
        cooldown=nil
    })
end

function CarC:Destroy()
    self._maid:Destroy()
end

return CarC