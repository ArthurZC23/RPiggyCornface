local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local BinderUtils = Mod:find({"Binder", "Utils"})
local WaitFor = Mod:find({"WaitFor", "WaitFor"})

local RootF = script:FindFirstAncestor("CarS")
local Components = {}
local CarSeat = require(ComposedKey.getAsync(RootF, {"Components", "Seats", "CarSeatS"}))

local CarS = {}
CarS.__index = CarS
CarS.className = "CarS"
CarS.TAG_NAME = CarS.className

function CarS.new(rootModel)
    local carMId = rootModel:GetAttribute("CarModelId")
    assert(carMId ~= nil, "CarS needs Model Id.")

    local self = {
        rootModel = rootModel,
        carMId = carMId,
        _maid = Maid.new(),
    }
    setmetatable(self, CarS)

    self:createRemotes()
    self:createAttributes()

    self:addTags()
    if not self:getFields() then return end
    -- if not BinderUtils.initComponents(self, Components) then return end
    if not self:initSeats() then return end

    return self
end

function CarS:addTags()
    for _, tag in ipairs({"Vehicle", "Chassis", "Seats"}) do
        CollectionService:AddTag(self.rootModel, tag)
    end
end

function CarS:initSeats()
    local SeatsM = self.carObj.car.SeatsS
    self.seats = SeatsM:GetChildren()
    for _, seat in ipairs(self.seats) do
        local seatObj = CarSeat.new(seat, self.carObj)
        if not seatObj then return end
        self._maid:Add(seatObj)
    end
    return true
end

function CarS:createAttributes()
    self.rootModel:SetAttribute("Throttle", 0)
    self.rootModel:SetAttribute("Steering", 0)
    self.rootModel:SetAttribute("HandBrake", 0)
end

function CarS:getFields()
    return WaitFor.GetAsync({
        getter=function()
            local bindersData = {
                {"Vehicle", self.rootModel},
                {"Chassis", self.rootModel},
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

local GaiaServer = Mod:find({"Gaia", "Server"})
function CarS:createRemotes()
    self._maid:Add(GaiaServer.createBinderRemotes(self, self.rootModel, {
        events = {"SetThrottle",},
        functions = {},
    }))
end

function CarS:Destroy()
    self._maid:Destroy()
end

return CarS