local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Assets = ReplicatedFirst.Assets
local Animations = Assets.Animations

local module = {}

task.defer(function()
    local animations = {}
    for _, desc in ipairs(Animations:GetDescendants()) do
        if desc:IsA("Animation") then
            table.insert(animations, desc)
        end
    end
    ContentProvider:PreloadAsync(animations)
end)

return module