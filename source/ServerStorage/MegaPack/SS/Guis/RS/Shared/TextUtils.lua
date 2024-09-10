local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ComposedKey = require(ReplicatedStorage.TableUtils.ComposedKey)
local Mod = require(ComposedKey.getAsync(ReplicatedStorage, {"Sherlocks", "Shared", "Mod"}))
local Cronos = Mod:find({"Cronos", "Cronos"})
local Math = Mod:find({"Math", "Math"})

local module = {}

function module.lerp(text, target, t, epi, kwargs)
    epi = epi or 1e-3
    local x = tonumber(text.Text)
    local speed = (target - x) / t

    local conn
    conn = RunService.Heartbeat:Connect(function(step)
        x += speed * step
        text.Text = tostring(x)
        if math.abs(x - target) <= epi then
            conn:Disconnect()
            conn = nil
            text.Text = target
        end
    end)
end

function module.lerpAsync(text, target, t, epi, kwargs)
    epi = epi or 1e-3
    local x = tonumber(text.Text)

    local speed = (target - x) / t
    if kwargs.roundSpeed then
        speed = math.floor(speed)
    end

    while math.abs(x - target) > epi do
        local step = RunService.Heartbeat:Wait()
        x += speed * step
        print("X: ", x)
        if kwargs.roundValue then
            x = kwargs.roundValue(x)
        end
        text.Text = tostring(x)
    end
    text.Text = target
end

-- function module.lerpCountAsync(text, target, t, step, epi)
--     epi = epi or 1e-3
--     local x = tonumber(text.Text)

--     local speed = math.floor((target - x) / t)
--     local dir = Math.sign(speed)

--     local currentDir
--     while math.abs(x - target) > epi do
--         Cronos.wait(step/speed)
--         x += dir * step
--         currentDir = 
--         text.Text = tostring(x)
--     end
--     text.Text = tostring(target)
-- end

return module