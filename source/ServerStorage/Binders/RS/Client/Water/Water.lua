local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Maid = Mod:find({"Maid"})

local Water = {}
Water.__index = Water
Water.className = "Water"
Water.TAG_NAME = Water.className

function Water.new(water)
    local self = {
        water = water,
        texture = water.Texture,
        randomX = Random.new(),
        randomY = Random.new(),
    }
    setmetatable(self, Water)

    self:simulateWaterMotion()

    return nil
end

function Water:simulateWaterMotion()
    local t = 0
    local dir = Vector2.new(1, 1).Unit
    local min = -1e-2
    local max = 2e-2
    RunService.Heartbeat:Connect(function(step)
        local omega = self.water:GetAttribute("omega")
        t += step
        local u = 100 * math.sin(omega * t)
        local v = 100 * math.cos(omega * t)
        -- dir = Vector2.new(u, v).Unit
        self.texture.OffsetStudsU = u
        self.texture.OffsetStudsV = v

        if t > 1e9 then
            t = 0
        end
        -- if self.texture.OffsetStudsU > 1e12 then
        --     self.texture.OffsetStudsU = 0
        -- end
        -- if self.texture.OffsetStudsV > 1e12 then
        --     self.texture.OffsetStudsV = 0
        -- end
    end)
end

function Water:Destroy()

end

return Water