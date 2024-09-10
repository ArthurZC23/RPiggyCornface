local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})
local Cronos = Mod:find({"Cronos", "Cronos"})
local FastSpawn = Mod:find({"FastSpawn"})
local SharedSherlock = Mod:find({"Sherlocks", "Shared"})
local Data = Mod:find({"Data", "Data"})
local LightingConfigs = Data.Lighting.Lighting.configs
local LorenzData = Data.Lorenz.Lorenz
local S = Data.Strings.Strings
local TableUtils = Mod:find({"Table", "Utils"})
local SingletonsManager = Mod:find({"Singleton", "Manager"})

local LorenzS = {}
LorenzS.__index = LorenzS
LorenzS.className = "Lorenz"
LorenzS.TAG_NAME = LorenzS.className

function LorenzS.new()
    local self = {}
    setmetatable(self, LorenzS)
    self:handleWind()

    return self
end

function LorenzS:handleWind()

end

function LorenzS:Destroy()
    self._maid:Destroy()
end

SingletonsManager.addSingleton(LorenzS.className, LorenzS.new())

return LorenzS