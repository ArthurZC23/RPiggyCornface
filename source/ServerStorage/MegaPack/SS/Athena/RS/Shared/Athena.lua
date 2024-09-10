local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local Promise = Mod:find({"Promise", "Promise"})

local Athena = {}
Athena.__index = Athena
Athena.className = "Athena"
Athena.TAG_NAME = Athena.className

function Athena.new()
    local self = {
        _maid = Maid.new(),
        data = {},
        structures = {},
        cleaners = {},
        enrichers = {},
        validators = {},
    }
    setmetatable(self, Athena)

    return self
end

function Athena:addData(newData)
    TableUtils.complementRestrained(self.data, newData)
end

function Athena:addStructures(structures)
    TableUtils.concatArrays(self.structures, structures)
end

function Athena:addCleaners(cleaners)
    TableUtils.concatArrays(self.cleaners, cleaners)
end

function Athena:addEnrichers(enrichers)
    TableUtils.concatArrays(self.enrichers, enrichers)
end

function Athena:addValidators(validators)
    TableUtils.concatArrays(self.validators, validators)
end

function Athena:structure()
    for _, struct in ipairs(self.structures) do
        struct(self.data)
    end
end

function Athena:clean()
    for _, cleaner in ipairs(self.cleaners) do
        cleaner(self.data)
    end
end

function Athena:enrich()
    for _, enrich in ipairs(self.enrichers) do
        enrich(self.data)
    end
end

function Athena:validate()
    for _, validate in ipairs(self.validators) do
        validate(self.data)
    end
end

function Athena:setStrategy()
    error("Need to finish graph library")
end

function Athena:publish()
    -- Need to finish graph library
    -- self.strategy = self.strategy or {
    --     root = self.structure,

    -- }
    return Promise.try(function()
        self:structure()
        self:clean()
        self:enrich()
        self:validate()
    end)
end

function Athena:Destroy()
    self._maid:Destroy()
end

return Athena