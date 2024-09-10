local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Data = Mod:find({"Data", "Data"})
local Platform = Mod:find({"Platform"})
local ContextActions = Data.ContextActions.ContextActions
local Keymap = Data.Vehicles.Car.Keymap[Platform]

local CAS = {}
CAS.__index = CAS
CAS.className = "CAS"
CAS.TAG_NAME = CAS.className

function CAS.new(carBinder)
    local self = {
        carBinder = carBinder,
        _maid = Maid.new(),
    }
    setmetatable(self, CAS)
    self:bindActions()

    return self
end

function CAS:bindActions()
    ContextActionService:BindAction(
        ContextActions.EXIT_ACTION_NAME,
        function() self.carBinder:exitVehicle() end,
        false,
        Keymap.EnterVehicleKeyboard
    )

    ContextActionService:BindActionAtPriority(
        ContextActions.RAW_INPUT_ACTION_NAME,
        function() self.carBinder:_updateRawInput() end,
        false,
        Enum.ContextActionPriority.High.Value,
        unpack(Keymap.keys)
    )

    self._maid:Add(function()
        self:unbindActions()
    end)
end

function CAS:unbindActions()

end

function CAS:Destroy()
    self._maid:Destroy()
end

return CAS